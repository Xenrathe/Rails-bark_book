class AddLocationPermissionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :location_permission, :boolean, default: false
  end
end
