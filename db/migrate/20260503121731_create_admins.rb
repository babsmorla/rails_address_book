class CreateAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :admins, id: false do |t|
      t.string :role_code, null: false, primary_key: true
      t.string :name

      t.timestamps
    end
  end
end
