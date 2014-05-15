class AddColumnsToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :email, :string
    add_column :admins, :password, :string
  end
end
