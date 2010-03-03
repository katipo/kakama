class EmailLog < ActiveRecord::Base
  belongs_to :staff
  belongs_to :event

  validates_presence_of :email_type, :staff_id

  def authorized_for_create?
    false
  end

  def authorized_for_update?
    false
  end
end
