class AddMaxLengthToComments < ActiveRecord::Migration[7.0]
  def change
    change_column :comments, :body, :text, limit: 250
  end
end
