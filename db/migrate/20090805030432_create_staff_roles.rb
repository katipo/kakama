class CreateStaffRoles < ActiveRecord::Migration
  def self.up
    create_table :staff_roles do |t|
      t.integer :staff_id, :null => false
      t.integer :role_id,  :null => false
      t.timestamps
    end

    add_index :staff_roles, [:staff_id, :role_id]
  end

  def self.down
    drop_table :staff_roles
  end
end
