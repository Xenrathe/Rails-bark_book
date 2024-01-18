class DogPark < ApplicationRecord
  include Enums

  has_many :play_dates, dependent: :destroy
  has_many :dog_park_followings, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :comments, as: :commentable

  validates :name, :dog_size, presence: true
end
