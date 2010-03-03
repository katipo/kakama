class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :venue_id,        :null => false
      t.boolean :recurring
      t.integer :schedule_id,     :null => false
      t.string :name,             :null => false
      t.text :description
      t.datetime :start_datetime, :null => false
      t.datetime :end_datetime,   :null => false
      t.integer :organiser_id,    :null => false
      t.string :state,            :null => false
      t.text :roles
      t.datetime :deleted_at
      t.timestamps
    end

    [:venue_id, :schedule_id, :start_datetime,
     :end_datetime, :organiser_id, :deleted_at].each do |field|
      add_index :events, field
    end
  end

  def self.down
    drop_table :events
  end
end
