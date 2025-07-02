class CreateBotTrapLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :bot_trap_logs do |t|
      t.string :ip
      t.string :user_agent
      t.string :reason
      t.json :metadata

      t.timestamps
    end
  end
end
