class Dog < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :contents, dependent: :destroy

  has_many :followings, dependent: :destroy
  has_many :followers, through: :followings, source: :user

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :attendee, resize_to_limit: [100, 100]
  end

  has_and_belongs_to_many :play_dates, class_name: 'PlayDate', join_table: 'dogs_play_dates'
  has_many :barks, as: :barkable, dependent: :destroy

  validates :birthdate, comparison: { less_than: DateTime.now }
  validates :name, :breed, :weight, :birthdate, presence: true
  validates :weight, comparison: { greater_than: 0 }
  validate :avatar_presence, on: %i[create update]

  scope :small, -> { where('weight <= ?', 25) }
  scope :large, -> { where('weight > ?', 25) }

  def self.nearby(user, location, distance)
    return if location.nil?

    # Add user's own dogs always
    nearby_dogs = user ? [user.dogs] : []

    # Then find nearby dogs
    if location.is_a?(Address)
      location.nearbys(distance)&.where('addressable_type = ?', 'User')&.each do |address|
        nearby_dogs << address.addressable.dogs if User.find(address.addressable_id).primary_address.id == address.id
      end
    else
      Address.near(location, distance)&.where('addressable_type = ?', 'User')&.each do |address|
        nearby_dogs << address.addressable.dogs if User.find(address.addressable_id).primary_address.id == address.id
      end
    end
    nearby_dogs.flatten
  end

  private

  def avatar_presence
    errors.add(:avatar, " must be attached") unless avatar.attached?
  end
end
