class CreatePlayDatesDogsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :play_dates, :dogs do |t|
      t.index [:play_date_id, :dog_id]
      t.index [:dog_id, :play_date_id]
    end
  end
end
