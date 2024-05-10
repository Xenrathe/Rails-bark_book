class DogPark < ApplicationRecord
  include Enums

  has_many :play_dates, dependent: :destroy
  has_many :dog_park_followings, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :comments, as: :commentable, dependent: :destroy

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  validates :name, :dog_size, presence: true
  validate :image_validations

  def self.nearby(location, distance)
    return if location.nil?

    addresses = if location.is_a?(Address)
                  location.nearbys(distance)
                else
                  Address.near(location, distance)
                end&.where('addressable_type = ?', 'DogPark')&.includes(:addressable).to_a

    addresses.map do |address|
      [address.addressable, address.distance_from(location)]
    end
  end

  private

  def image_validations
    attached_images.each do |image|
      errors.add(:attached_images, ' cannot be larger than 10MB') if image.byte_size > 10.megabytes
      errors.add(:attached_images, ' must be image files') unless image.content_type.start_with?('image/')
    end
  end

end
