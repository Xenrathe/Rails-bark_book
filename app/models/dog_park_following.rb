class DogParkFollowing < ApplicationRecord
  belongs_to :user
  belongs_to :dog_park
end