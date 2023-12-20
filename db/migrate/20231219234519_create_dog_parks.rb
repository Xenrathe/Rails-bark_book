class CreateDogParks < ActiveRecord::Migration[7.0]
  def change
    create_table :dog_parks do |t|
      t.string :name, null: false
      t.integer :dog_size, null: false

      t.timestamps
    end
  end
end
