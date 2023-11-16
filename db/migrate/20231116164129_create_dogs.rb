class CreateDogs < ActiveRecord::Migration[7.0]
  def change
    create_table :dogs do |t|
      t.integer :age
      t.string :breed
      t.string :name
      t.integer :weight

      t.timestamps
    end
  end
end
