class AdjustDogSizeInPlayDate < ActiveRecord::Migration[7.0]
  def change
    change_column :play_dates, :dog_size, :integer, null: false, default: 2
  end
end
