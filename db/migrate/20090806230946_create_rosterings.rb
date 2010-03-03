class CreateRosterings < ActiveRecord::Migration
  def self.up
    create_table :rosterings do |t|
      t.integer :staff_id, :null => false
      t.integer :event_id, :null => false
      t.integer :role_id,  :null => false
      t.string  :state,    :null => false
      t.boolean :system_flagged
      t.timestamps
    end

    [:staff_id, :event_id, :role_id].each do |field|
      add_index :rosterings, field
    end
  end

  def self.down
    drop_table :rosterings
  end
end
