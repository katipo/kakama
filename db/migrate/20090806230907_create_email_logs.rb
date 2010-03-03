class CreateEmailLogs < ActiveRecord::Migration
  def self.up
    create_table :email_logs do |t|
      t.string :email_type, :null => false
      t.string :subject,    :null => false
      t.integer :staff_id,  :null => false
      t.integer :event_id
      t.timestamps
    end

    add_index :email_logs, [:staff_id, :event_id]
  end

  def self.down
    drop_table :email_logs
  end
end
