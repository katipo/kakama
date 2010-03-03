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
