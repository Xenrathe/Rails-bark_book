class ChangeDefaultNumInBarks < ActiveRecord::Migration[7.0]
  def change
    change_column_default :barks, :num, 1
  end
end
