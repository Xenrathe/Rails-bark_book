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
  scope :in_my_city, lambda { |current_user|
    joins("INNER JOIN addresses ON addresses.user_id = users.id AND addresses.id = (SELECT id FROM addresses WHERE user_id = users.id ORDER BY created_at LIMIT 1)")
      .where('addresses.city = ? AND addresses.state = ?', current_user.addresses.first.city, current_user.addresses.first.state)
  }

  private

  def avatar_presence
    errors.add(:avatar, " must be attached") unless avatar.attached?
  end
end
