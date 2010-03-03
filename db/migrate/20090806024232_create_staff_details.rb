class CreateStaffDetails < ActiveRecord::Migration
  def self.up
    create_table :staff_details do |t|
      t.integer :staff_id,       :null => false
      t.integer :detail_type_id, :null => false
      t.text :value,             :null => false
      t.timestamps
    end

    [:staff_id, :detail_type_id].each do |field|
      add_index :staff_details, field
    end
  end

  def self.down
    drop_table :staff_details
  end
end
