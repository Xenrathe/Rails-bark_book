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
  validate :at_least_one_dog_selected, on: %i[create update]

  private

  def at_least_one_dog_selected
    if dogs.none?
      errors.add(:base, "Content must be about at least one dog.")
    end
  end

  def content_limitations
    case content_type
    when 'image'
      errors.add(:image, ' must be attached') unless attached_images.attached?
      errors.add(:caption, ' cannot be greater than 200 characters') unless body.length <= 200
      errors.add(:attached_images, ' cannot exceed 10 files') if attached_images.count > 10
      attached_images.each do |image|
        errors.add(:attached_images, ' cannot be larger than 10MB') if image.byte_size > 10.megabytes
        errors.add(:attached_images, ' must be image files') unless image.content_type.start_with?('image/')
      end
    when 'video'
      errors.add(:video, ' must be attached') unless attached_video.attached?
      errors.add(:caption, ' cannot be greater than 200 characters') unless body.length <= 200
      errors.add(:attached_video, ' cannot be larger than 150MB') if attached_video.byte_size > 150.megabytes
      errors.add(:attached_video, ' must be a video file') unless attached_video.content_type.start_with?('video/')
    when 'post'
      errors.add(:body, ' must be between 10 and 2000 characters') unless body.length >= 10 && body.length <= 2000
    end
  end
end
