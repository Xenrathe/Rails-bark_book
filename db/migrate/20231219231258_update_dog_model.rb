class UpdateDogModel < ActiveRecord::Migration[7.0]
  def change
    remove_column :dogs, :age
    add_column :dogs, :birthdate, :date
    add_reference :dogs, :user, null: false, foreign_key: true
  end
end
