class CreateFollowings < ActiveRecord::Migration[7.0]
  def change
    create_table :followings do |t|
      t.references :user, foreign_key: true
      t.references :dog, foreign_key: true
      t.timestamps
    end
  end
end
