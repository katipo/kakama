# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :string(255)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Role < ActiveRecord::Base
  has_many :staff_roles
  has_many :staff, :through => :staff_roles

  validates_presence_of :name
  validates_uniqueness_of :name

  before_destroy :ensure_role_deletable

  include SoftDelete

  def assigned_to_staff?
    staff_roles.size > 0
  end

  def authorized_for_destroy?
    !assigned_to_staff?
  end

  def total_assigned
    staff_roles.count
  end

  def staff_available_for(event)
    raise "ERROR: staff_available_for expects to be passed an Event instance" unless event.is_a?(Event)
    Setting.administrators_can_be_rostered ? staff.available_for(event) : staff.members.available_for(event)
  end

  private

  def ensure_role_deletable
    if assigned_to_staff?
      errors[:base] << 'You cannot delete this role because it is still assigned to staff members.'
      false
    else
      true
    end
  end
end
