class CreateDogContents < ActiveRecord::Migration[7.0]
  def change
    create_table :dog_contents do |t|
      t.references :dog, null: false, foreign_key: true
      t.references :content, null: false, polymorphic: true
      
      t.timestamps
    end
  end
end
