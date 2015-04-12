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

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
