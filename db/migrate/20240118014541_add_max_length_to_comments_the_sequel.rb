class AddMaxLengthToCommentsTheSequel < ActiveRecord::Migration[7.0]
  def change
    change_column :comments, :body, :string, limit: 250
  end
end
