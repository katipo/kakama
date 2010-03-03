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
