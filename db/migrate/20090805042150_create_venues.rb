class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table :venues do |t|
      t.string :name,      :null => false
      t.text :description
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :venues, :name, :unique => true
    add_index :venues, :deleted_at
  end

  def self.down
    drop_table :venues
  end
end
