class StaffDetail < ActiveRecord::Base
  belongs_to :detail_type
  belongs_to :staff

  validates_presence_of :detail_type_id, :staff_id

  scope :postal_address, lambda { { :conditions => { :detail_type_id => DetailType.find_by_name('Postal Address').id } } }
  scope :physical_address, lambda { { :conditions => { :detail_type_id => DetailType.find_by_name('Physical Address').id } } }
end
