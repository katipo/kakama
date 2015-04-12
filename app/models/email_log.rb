# == Schema Information
#
# Table name: email_logs
#
#  id         :integer          not null, primary key
#  email_type :string(255)      not null
#  subject    :string(255)      not null
#  staff_id   :integer          not null
#  event_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

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
