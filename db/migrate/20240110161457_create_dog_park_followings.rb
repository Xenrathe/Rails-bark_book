class CreateDogParkFollowings < ActiveRecord::Migration[7.0]
  def change
    create_table :dog_park_followings do |t|
      t.references :dog_park, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
