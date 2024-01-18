class AddNotNullToDogs < ActiveRecord::Migration[7.0]
  def change
    change_column :dogs, :breed, :string, null: false
    change_column :dogs, :name, :string, null: false
    change_column :dogs, :weight, :integer, null: false
    change_column :dogs, :birthdate, :datetime, null: false
  end
end
