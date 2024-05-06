class DropSplitContents < ActiveRecord::Migration[7.0]
  def change
    drop_table :posts
    drop_table :images
    drop_table :videos
  end
end
