class DogPark < ApplicationRecord
  has_one :address, as: :addressable
  has_many :comments, as: :commentable
end
