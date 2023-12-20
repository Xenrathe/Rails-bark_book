class Dog < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :contents, polymorphic: true
  has_one_attached :avatar
  has_and_belongs_to_many :play_dates, class_name: 'PlayDate', join_table: 'play_dates_dogs'
  has_many :barks, as: :barkable

  scope :small, -> { where('weight <= ?', 25) }
  scope :large, -> { where('weight > ?', 25) }
  scope :in_my_city, lambda { |current_user|
    joins("INNER JOIN addresses ON addresses.user_id = users.id AND addresses.id = (SELECT id FROM addresses WHERE user_id = users.id ORDER BY created_at LIMIT 1)")
      .where('addresses.city = ? AND addresses.state = ?', current_user.addresses.first.city, current_user.addresses.first.state)
  }
end
