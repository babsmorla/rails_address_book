class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin_role_code, :string


    add_foreign_key :users, :admins, column: :admin_role_code, primary_key: :role_code
  end
end
