class CreateStaffs < ActiveRecord::Migration
  def self.up
    create_table :staffs do |t|
      t.string :username,          :null => false
      t.string :staff_type,        :null => false
      t.string :crypted_password,  :null => false
      t.string :email
      t.string :full_name,         :null => false
      t.date :start_date,          :null => false
      t.text :admin_notes
      t.datetime :deleted_at
      t.timestamps

      # authlogic required columns
      t.string :password_salt,     :null => false  # encryption
      t.string :persistence_token, :null => false  # stay logged in
      t.string :perishable_token,  :null => false  # password reset
      t.datetime :last_request_at                  # session timeout support
    end

    [:username, :full_name, :start_date].each do |field|
      add_index :staffs, field
    end
  end

  def self.down
    drop_table :staffs
  end
end
