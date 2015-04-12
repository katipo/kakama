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

class DetailType < ActiveRecord::Base
  has_many :staff_details, :dependent => :destroy

  validates_presence_of :name, :field_type
  validates_uniqueness_of :name

  include SoftDelete

  Types = [
    ['Single Line Value', 'string'],
    ['Multi Line Value', 'text']
  ]
end
