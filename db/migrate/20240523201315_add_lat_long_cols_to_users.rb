class AddLatLongColsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :latitude, :float, default: nil
    add_column :users, :longitude, :float, default: nil
  end
end
