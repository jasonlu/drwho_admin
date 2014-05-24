class AddColumnsToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :roles_mask, :integer
  end
end
