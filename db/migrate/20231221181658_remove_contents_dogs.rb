class RemoveContentsDogs < ActiveRecord::Migration[7.0]
  def change
    drop_table :contents_dogs
  end
end
