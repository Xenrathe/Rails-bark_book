class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :address_one, null: false
      t.string :address_two
      t.string :city, null: false
      t.string :state
      t.string :postal_code
      t.string :country, null: false
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
