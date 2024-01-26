class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :addresses, as: :addressable
  belongs_to :primary_address, class_name: 'Address', optional: true
  has_many :dogs, dependent: :destroy
  has_many :contents, dependent: :destroy
  has_many :play_dates, dependent: :destroy
  has_many :comments
  has_many :barks

  has_many :followings, dependent: :destroy
  has_many :followed_dogs, through: :followings, source: :dog

  has_many :dog_park_followings, dependent: :destroy
  has_many :followed_dog_parks, through: :dog_park_followings, source: :dog_park

  has_one_attached :custom_bark

  validates :email, :time_zone, presence: true
  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }

  def follow(object)
    if object.class.name.downcase == 'dog'
      followed_dogs << object unless following?(object)
    elsif object.class.name.downcase == 'dogpark'
      followed_dog_parks << object unless following?(object)
    end
  end

  def unfollow(object)
    if object.class.name.downcase == 'dog'
      followed_dogs.delete(object)
    elsif object.class.name.downcase == 'dogpark'
      followed_dog_parks.delete(object)
    end
  end

  def following?(object)
    followed_dogs.include?(object) || followed_dog_parks.include?(object)
  end
end
