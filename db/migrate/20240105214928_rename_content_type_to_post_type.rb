class RenameContentTypeToPostType < ActiveRecord::Migration[7.0]
  def change
    rename_column :contents, :type, :content_type
  end
end
