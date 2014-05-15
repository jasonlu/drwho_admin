class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :serial_id, :string
  end
end
