class AddSingleAccessTokenToStaff < ActiveRecord::Migration
  def change
    add_column :staffs, :single_access_token, :string, null: false, default: ''
  end
end
