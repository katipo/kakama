class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :name,      :null => false
      t.integer :interval, :null => false
      t.string :delay,     :null => false
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
