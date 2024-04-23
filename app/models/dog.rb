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

  def self.nearby(location, distance)
    return if location.nil?

    addresses = location.is_a?(Address) ? location.nearbys(distance).where('addressable_type = ?', 'User').to_a : Address.near(location, distance).where('addressable_type = ?', 'User').to_a
    Dog.joins(user: :addresses).where('addresses.id = users.primary_address_id AND users.id IN (?)', addresses.pluck(:addressable_id))  
  end

  private

  def avatar_presence
    errors.add(:avatar, " must be attached") unless avatar.attached?
    errors.add(:avatar, ' cannot be larger than 10MB') if avatar.byte_size > 10.megabytes
    errors.add(:avatar, ' must be an image file') unless avatar.content_type.start_with?('image/')
  end
end
