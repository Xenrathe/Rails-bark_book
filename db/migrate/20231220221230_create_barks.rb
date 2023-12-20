class CreateBarks < ActiveRecord::Migration[7.0]
  def change
    create_table :barks do |t|
      t.bigint :num, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :barkable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
