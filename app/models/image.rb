class Image < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :dogs, as: :contents
  has_many_attached :images
  has_many :comments, as: :commentable
  has_many :barks, as: :barkable
end
