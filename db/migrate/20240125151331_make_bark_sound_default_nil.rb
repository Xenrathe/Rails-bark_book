class MakeBarkSoundDefaultNil < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :bark_sound, nil
  end
end
