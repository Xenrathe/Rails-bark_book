class RenameDogContentToDogsContents < ActiveRecord::Migration[7.0]
  def change
    rename_table :dog_contents, :dogs_contents
  end
end
