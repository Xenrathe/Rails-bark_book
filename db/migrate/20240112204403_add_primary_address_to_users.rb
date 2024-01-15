class AddPrimaryAddressToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :primary_address, foreign_key: { to_table: :addresses }
  end
end
