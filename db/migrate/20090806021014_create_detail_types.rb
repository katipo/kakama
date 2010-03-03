class CreateDetailTypes < ActiveRecord::Migration
  def self.up
    create_table :detail_types do |t|
      t.string :name,       :null => false
      t.string :field_type, :null => false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :detail_types, :name, :unique => true
  end

  def self.down
    drop_table :detail_types
  end
end
