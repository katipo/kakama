# == Schema Information
#
# Table name: staffs
#
#  id                :integer          not null, primary key
#  username          :string(255)      not null
#  staff_type        :string(255)      not null
#  crypted_password  :string(255)      not null
#  email             :string(255)
#  full_name         :string(255)      not null
#  start_date        :date             not null
#  admin_notes       :text
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  password_salt     :string(255)      not null
#  persistence_token :string(255)      not null
#  perishable_token  :string(255)      not null
#  last_request_at   :datetime
#

require 'test_helper'

class StaffTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
