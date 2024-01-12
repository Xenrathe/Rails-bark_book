class RemoveNullRequirementFromUserIdInBarksAndComments < ActiveRecord::Migration[7.0]
  def change
    change_column :comments, :user_id, :bigint, null: true
    remove_foreign_key :comments, :users
    add_foreign_key :comments, :users, on_delete: :nullify

    change_column :barks, :user_id, :bigint, null: true
    remove_foreign_key :barks, :users
    add_foreign_key :barks, :users, on_delete: :nullify
  end
end
