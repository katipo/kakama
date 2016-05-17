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

require 'test_helper'

class EmailLogTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
