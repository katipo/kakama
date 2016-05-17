# == Schema Information
#
# Table name: rosterings
#
#  id             :integer          not null, primary key
#  staff_id       :integer          not null
#  event_id       :integer          not null
#  role_id        :integer          not null
#  state          :string(255)      not null
#  system_flagged :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class RosteringTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
