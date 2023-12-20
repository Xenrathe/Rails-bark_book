class UpdateAddressModel < ActiveRecord::Migration[7.0]
  def change
    remove_reference :addresses, :user, foreign_key: true
    
    add_reference :addresses, :addressable, polymorphic: true, null: false
  end
end
