class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :addresses, as: :addressable
  has_many :dogs
  has_many :posts
  has_many :images
  has_many :videos
  has_many :play_dates
  has_many :comments
  has_many :barks

  has_many :followings, dependent: :destroy
  has_many :followed_dogs, through: :followings, source: :dog

  def follow(dog)
    followed_dogs << dog unless following?(dog)
  end

  def unfollow(dog)
    followed_dogs.delete(dog)
  end

  def following?(dog)
    followed_dogs.include?(dog)
  end
end
