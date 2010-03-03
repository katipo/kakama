class Rostering < ActiveRecord::Base
  belongs_to :staff
  belongs_to :event
  belongs_to :role

  validates_presence_of :staff_id, :event_id, :role_id, :state

  after_update :reselect_staff_to_fill_roles
  before_destroy :store_event_id_for_after_delete
  after_destroy :reselect_staff_to_fill_roles

  # Incase we are canceling multiple rosterings in one go, as is the case
  # when an event time has changed and staff become unavailable, or an
  # event is cancelled altogether, we don't want to regenerate the lists on
  # each cancelation
  attr_accessor :skip_staff_selections_callback

  States = {
    :unconfirmed => 'unconfirmed',
    :confirmed => 'confirmed',
    :rejected => 'rejected',
    :declined => 'declined',
    :cancelled => 'cancelled',
    :no_show => 'no_show'
  }

  named_scope :with_role, lambda { |role| { :conditions => { :role_id => role.id } } }
  named_scope :with_state, lambda { |states| { :conditions => { :state => states } } }
  named_scope :active_state, :conditions => { :state => [Rostering::States[:unconfirmed], Rostering::States[:confirmed]] }
  named_scope :inactive_state, :conditions => { :state => [Rostering::States[:rejected], Rostering::States[:declined], Rostering::States[:cancelled]] }
  named_scope :non_system_flagged, :conditions => { :system_flagged => false }
  named_scope :system_flagged, :conditions => { :system_flagged => true }

  Rostering::States.each do |key,state_value|
    named_scope key, :conditions => { :state => state_value }
    define_method "#{key.to_s}?" do
      state == state_value
    end
    define_method "#{key.to_s}!" do
      # Update wont raise add_to_base errors properly, so raise the first one manually
      update_attributes!(:state => state_value) rescue raise errors.full_messages.first
    end
  end

  # Overwrite the method generated earlier to send emails
  def confirmed!(send_notification=true)
    update_attribute(:state, Rostering::States[:confirmed])
    Notifier.deliver_email_or_pdf_of(:rostering_confirmed_notification, staff, event, role) if send_notification
  end

  # Overwrite the method generated earlier to send emails
  # If an event is cancelled, then each rostering is cancelled, but
  # we don't want to send out the standard 'your rostering cancelled' email
  # So not passing a reason will only update the state (no email sent)
  def cancelled!(reason=nil)
    update_attribute(:state, Rostering::States[:cancelled])
    Notifier.deliver_email_or_pdf_of(:rostering_cancelled_notification, staff, event, role, reason) unless reason.blank?
  end

  # schedule the expiration of the rostering to register their acceptance or rejection
  def queue_expiration
    # if there is no time to respond, don't do anything in this method
    return unless event.time_response_required_by
    # we use delayed job, enqueue same ruby which is eval'ed when the time comes
    # Keep it very simple. Find the rostering, and mark it declined if it exists and is still unconfirmed
    Delayed::Job.enqueue(0, event.time_response_required_by) do <<-JOB
      rostering = Rostering.find_by_id(#{id})
      rostering.update_attributes!({
        :state => Rostering::States[:declined],
        :system_flagged => true
      }) if rostering && rostering.unconfirmed?
    JOB
    end
  end

  def notify_staff_and_queue_expiration
    # if there is no time to respond, don't do anything in this method
    return unless event.time_response_required_by
    # send out an email asking for the staff to either accept or reject this event
    Notifier.deliver_email_or_pdf_of(:rostering_created_notification, staff, event, role)
    # schedule the expiration of the rostering to register their acceptance or rejection
    queue_expiration
  end

  private

  # Anything a rostering is edited or deleted,
  # the roles are recalculated to fill in any
  # spots that have opened up
  def reselect_staff_to_fill_roles
    return if skip_staff_selections_callback
    (@event || event).select_staff_to_fill_roles
  end

  def store_event_id_for_after_delete
    @event = event
  end
end
