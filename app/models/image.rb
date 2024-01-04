class Image < ApplicationRecord
  belongs_to :user
  has_many :dog_contents, as: :content, dependent: :destroy
  has_many :dogs, through: :dog_contents

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  has_many :comments, as: :commentable
  has_many :barks, as: :barkable
end
