class Content < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :dogs, dependent: :destroy

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :feedsize, resize_to_limit: [500, 500]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  has_one_attached :attached_video

  has_many :comments, as: :commentable
  has_many :barks, as: :barkable

  validate :content_limitations, on: %i[create update]

  private

  def content_limitations
    case content_type
    when 'image'
      puts "Image error found!"
      errors.add(:image, ' must be attached') unless attached_images.attached?
      errors.add(:caption, ' cannot be greater than 200 characters') unless body.length <= 200
      errors.add(:attached_images, ' cannot exceed 10 files') if attached_images.count > 10
    when 'video'
      errors.add(:video, ' must be attached') unless attached_video.attached?
      errors.add(:caption, ' cannot be greater than 200 characters') unless body.length <= 200
    when 'post'
      errors.add(:body, ' must be between 10 and 2000 characters') unless body.length >= 10 && body.length <= 2000
    end
  end
end
