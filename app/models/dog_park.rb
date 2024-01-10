class DogPark < ApplicationRecord
  include Enums
  
  has_one :address, as: :addressable
  accepts_nested_attributes_for :address
  has_many :comments, as: :commentable
end
