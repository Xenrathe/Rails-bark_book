class AddBarkSoundToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :bark_sound, :string, default: 'med_bark_3'
  end
end
