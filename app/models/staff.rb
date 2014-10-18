class Staff < ActiveRecord::Base
  has_many :staff_roles
  has_many :roles, :through => :staff_roles
  has_many :staff_details
  has_many :rosterings
  has_many :events, :through => :rosterings
  has_many :availability
  has_many :email_logs

  validates_presence_of :username, :staff_type, :full_name, :start_date
  validates_uniqueness_of :username
  validates_as_email_address :email, :allow_blank => true
  validate :validate_password, :on => :update

  after_save :setup_roles
  after_save :setup_contact_details
  after_create :send_notifying_email
  before_destroy :ensure_staff_deletable

  # will be used when changing the password on staff edit
  attr_accessor :current_password, :skip_current_password

  include SoftDelete

  acts_as_authentic do |c|
    c.validate_email_field = false
    c.logged_in_timeout = Setting.session_timeout.minutes
  end

  Types = [
    ['Site Administrator', 'admin'],
    ['Staff Member', 'staff']
  ]

  scope :administrators, :conditions => { :staff_type => 'admin' }
  scope :members, :conditions => { :staff_type => 'staff' }
  

  def self.available_for(event)
    all.select { |staff| staff.available_for?(event) }
  end

  def self.contact_all(options = {})
    return false if options[:subject].blank? || options[:body].blank?
    Notifier.deliver_email_or_pdf_of(:email_to_all_staff, Staff.all, options[:subject], options[:body])
    true
  end

  # Overwrite the role_id and role_ids= methods so we can convert the
  # strings into integers in an after_save callback
  def role_ids
    roles.collect { |r| r.id }
  end
  def role_ids=(value)
    @role_ids = value.map { |r| r.to_i }
  end

  # Overwrite the contact_details and contact_details= method sso we can
  # convert the data we get on staff forms into a format we can use in
  # an after_save callback and on staff edit forms
  def contact_details
    details = Hash.new
    staff_details.each { |d| details[d.detail_type_id] = d.value }
    details
  end
  def contact_details=(value)
    @contact_details = value
  end

  def type_label
    Staff::Types.select { |label, value| value == staff_type }.first.first
  end

  def deliver_password_reset_instructions!
    return false if email.blank?
    reset_perishable_token!
    Notifier.password_reset_instructions.deliver self
    true
  end

  # Used by ActiveScaffold for staff member display
  def to_label
    full_name
  end

  def availabilities_overlapping(start_date, end_date)
    availability(true).overlapping(start_date, end_date).sort_by(&:start_date)
  end

  # Does all the checks to see if this staff member can make it to an event
  # Make sure we reload the staff members availabilities/events so that any
  # changes made prior to this call are taken into account
  def available_for?(event, ignore_list=Array.new)
    event = Event.find(event) unless event.is_a?(Event)
    availability(true).wrapping(event.start_datetime, event.end_datetime).within_hours_of?(event) &&
    events(true).occuring_at(event.start_datetime, event.end_datetime).excluding(ignore_list).size == 0
  end

  def roster_to(event, role, ignore_unavailability=false, options={})
    event = Event.find(event) unless event.is_a?(Event)
    role = Role.find(role) unless role.is_a?(Role)
    return false unless ignore_unavailability || available_for?(event)

    # All rosterings are created in this method. We must prevent duplicate rosterings
    # Incase something went wrong somewhere, this is the final check. Get all rosterings,
    # passing in true to reload them, then check we don't already have a rostering for
    # this event and role
    if rosterings(true).find_by_event_id_and_role_id(event.id, role.id)
      false
    else
      rostering = rosterings.create!(
        :event_id => event.id,
        :role_id => role.id,
        :state => (options[:state] || Rostering::States[:unconfirmed])
      )

      rostering.notify_staff_and_queue_expiration if options[:send_notification_email]

      true
    end
  end

  def rosterings_at(event)
    rosterings(true).find_all_by_event_id(event)
  end

  def active_rosterings_at(event)
    rosterings(true).active_state.find_all_by_event_id(event)
  end

  def email_with_name
    if Setting.full_names_in_mails_headers
      "#{full_name} <#{email}>"
    else
      "#{login} <#{email}>"
    end
  end

  def contact(options = {})
    return false if options[:subject].blank? || options[:body].blank? || email.blank?
    Notifier.deliver_staff_email self, options[:subject], options[:body]
    true
  end

  def sending_address
    address = staff_details.postal_address.first
    address = staff_details.physical_address.first if address.blank?
    address ? address.value : ''
  end

  def detail_types_hash
    @detail_types_hash ||= begin
      details = Hash.new
      staff_details.each do |detail|
        details[detail.detail_type_id] = detail.value
      end
      details
    end
  end
  
  # This method has been created to replace the searchlogic functionality that is no longer available in Rails 3.2+
  def self.username_or_full_name_like(search_text, options={})
    search_text_parameter = "%#{search_text}%"
    search_query = 'username LIKE ? or full_name LIKE ?' 
    
    if options[:order_by]
      Staff.where(search_query, search_text_parameter, search_text_parameter).order(options[:order_by])
    else
      Staff.where(search_query, search_text_parameter, search_text_parameter)
    end
      
  end

  protected

  def ensure_staff_deletable
    if rosterings(true).active_state.size > 0
      errors.add_to_base("Unable to delete the staff member #{full_name}.
        They are currently unconfirmed or confirmed at one or more events.
        They need to be removed from these events before they can be deleted.")
      false
    else
      true
    end
  end

  def setup_roles
    return if @role_ids.blank?
    staff_roles.destroy_all # clear existing roles
    Role.find_all_by_id(@role_ids).each do |role|
      roles << role
    end
  end

  def setup_contact_details
    return if @contact_details.blank?
    staff_details.destroy_all # clear existing roles
    @contact_details.each do |detail_type_id, value|
      next if value.blank?
      StaffDetail.create!({
        :staff_id => self.id,
        :detail_type_id => detail_type_id.to_i,
        :value => value
      })
    end
  end

  # Current password must be set if password is being changed.
  # Doesn't apply to new records
  def validate_password
    if !new_record? && !password.blank? && !skip_current_password
      if current_password.blank?
        errors.add(:current_password, "must be set when changing the password.")
        return false
      elsif !valid_password?(current_password)
        errors.add(:current_password, "does not match your current password.")
        return false
      end
    end
    true
  end

  def send_notifying_email
    Notifier.deliver_email_or_pdf_of(:staff_account_creation, self)
  end
end
