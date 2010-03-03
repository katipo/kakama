class AddApproverIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :approver_id, :integer
  end

  def self.down
    remove_column :events, :approver_id
  end
end
