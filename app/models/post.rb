class Post < ApplicationRecord
  belongs_to :user
  has_many :dog_contents, as: :content, dependent: :destroy
  has_many :dogs, through: :dog_contents
  has_many :comments, as: :commentable
  has_many :barks, as: :barkable
end
