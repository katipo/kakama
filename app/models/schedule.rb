# == Schema Information
#
# Table name: schedules
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  interval   :integer          not null
#  delay      :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

# TODO: Complete implementation if budget permits
# Currently not implemented
class Schedule < ActiveRecord::Base
  has_many :events

  validates_presence_of :name, :interval, :delay

  include SoftDelete

  Delays = {
    :day => 'day',
    :week => 'week',
    :month => 'month'
  }

  Types = [
    ['Day(s)', Schedule::Delays[:day]],
    ['Week(s)', Schedule::Delays[:week]],
    ['Month(s)', Schedule::Delays[:month]]
  ]
end
