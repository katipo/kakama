# == Schema Information
#
# Table name: staff_details
#
#  id             :integer          not null, primary key
#  staff_id       :integer          not null
#  detail_type_id :integer          not null
#  value          :text             not null
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class StaffDetailTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
