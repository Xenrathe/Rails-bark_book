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
end
