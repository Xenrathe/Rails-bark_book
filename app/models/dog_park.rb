class DogPark < ApplicationRecord
  include Enums

  has_many :play_dates, dependent: :destroy
  has_many :dog_park_followings, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :comments, as: :commentable

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  validates :name, :dog_size, presence: true

  def self.nearby(location, distance)
    return if location.nil?

    nearby_dogparks = []
    if location.is_a?(Address)
      location.nearbys(distance)&.where('addressable_type = ?', 'DogPark')&.each do |address|
        nearby_dogparks << [address.addressable, address.distance_from(location)]
      end
    else
      Address.near(location, distance)&.where('addressable_type = ?', 'DogPark')&.each do |address|
        nearby_dogparks << [address.addressable, address.distance_from(location)]
      end
    end
    nearby_dogparks
  end

end
