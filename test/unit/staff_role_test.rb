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

require 'test_helper'

class StaffRoleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
