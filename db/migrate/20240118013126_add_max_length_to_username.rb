class AddMaxLengthToUsername < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :username, :string, limit: 25
  end
end
