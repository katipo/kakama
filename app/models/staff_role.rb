# == Schema Information
#
# Table name: staff_roles
#
#  id         :integer          not null, primary key
#  staff_id   :integer          not null
#  role_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class StaffRole < ActiveRecord::Base
  belongs_to :role
  belongs_to :staff

  validates_presence_of :role_id, :staff_id
end
