class CreateAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :availabilities do |t|
      t.integer :staff_id, :null => false
      t.date :start_date,  :null => false
      t.date :end_date,    :null => false
      t.text :hours,       :null => false
      t.boolean :admin_locked
      t.timestamps
    end

    [:staff_id, :start_date, :end_date].each do |field|
      add_index :availabilities, field
    end
  end

  def self.down
    drop_table :availabilities
  end
end
