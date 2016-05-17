# == Schema Information
#
# Table name: detail_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  field_type :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class DetailTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
