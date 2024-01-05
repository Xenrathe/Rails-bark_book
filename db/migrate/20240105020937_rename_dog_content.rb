class RenameDogContent < ActiveRecord::Migration[7.0]
  def change
    rename_table :dog_contents, :contents_dogs
  end
end
