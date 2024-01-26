class ChangeDefaultForBarkSoundToMute < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :bark_sound, "mute"
  end
end
