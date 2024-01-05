class Content < ApplicationRecord
  belongs_to :user

  #has_many :dog_contents, dependent: :destroy
  has_and_belongs_to_many :dogs, dependent: :destroy

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  has_one_attached :attached_video

  has_many :comments, as: :commentable
  has_many :barks, as: :barkable
end
