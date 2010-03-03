class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name, :null => false
      t.string :description
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :roles, :name, :unique => true
  end

  def self.down
    drop_table :roles
  end
end
