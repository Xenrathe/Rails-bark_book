class RenameDogContentsToContentsDogs < ActiveRecord::Migration[7.0]
  def change
    rename_table :dogs_contents, :contents_dogs
  end
end
