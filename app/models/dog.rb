class Dog < ApplicationRecord
  belongs_to :user

  has_many :dog_contents, dependent: :destroy
  has_many :contents, through: :dog_contents, source: :content, source_type: 'Content'

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
  end
  
  has_and_belongs_to_many :play_dates, class_name: 'PlayDate', join_table: 'dogs_play_dates'
  has_many :barks, as: :barkable

  scope :small, -> { where('weight <= ?', 25) }
  scope :large, -> { where('weight > ?', 25) }
  scope :in_my_city, lambda { |current_user|
    joins("INNER JOIN addresses ON addresses.user_id = users.id AND addresses.id = (SELECT id FROM addresses WHERE user_id = users.id ORDER BY created_at LIMIT 1)")
      .where('addresses.city = ? AND addresses.state = ?', current_user.addresses.first.city, current_user.addresses.first.state)
  }
end
