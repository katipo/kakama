class StaffRole < ActiveRecord::Base
  belongs_to :role
  belongs_to :staff

  validates_presence_of :role_id, :staff_id
end
