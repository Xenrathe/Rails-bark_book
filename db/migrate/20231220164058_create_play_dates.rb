class CreatePlayDates < ActiveRecord::Migration[7.0]
  def change
    create_table :play_dates do |t|
      t.datetime :date, null: false
      t.text :description
      t.references :dog_park, null: false, foreign_key: true
      t.integer :dog_size
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
