class CreateDogContentsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :dog_contents, id: false do |t|
      t.references :dog, foreign_key: true
      t.references :content, polymorphic: true, index: { name: 'index_dog_contents_on_content_type_and_content_id' }

      t.timestamps
    end
  end
end
