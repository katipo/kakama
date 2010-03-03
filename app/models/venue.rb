class Venue < ActiveRecord::Base
  has_many :events

  validates_presence_of :name
  validates_uniqueness_of :name

  before_destroy :ensure_no_unfinished_events

  include SoftDelete

  def has_unfinished_events?
    events.count(:conditions => ["end_datetime > ?", Time.now.utc]) > 0
  end

  def authorized_for_destroy?
    !has_unfinished_events?
  end

  protected

  def ensure_no_unfinished_events
    if has_unfinished_events?
      errors.add_to_base("You cannot delete this venue because it contains unfinished events.")
      false
    else
      true
    end
  end
end
