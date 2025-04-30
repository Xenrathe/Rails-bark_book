class Content < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :dogs, dependent: :destroy

  has_many_attached :attached_images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :feedsize, resize_to_limit: [500, 500]
    attachable.variant :midsize, resize_to_limit: [1000, 1000]
  end

  # NOTE: this process_video MUST be listed BEFORE attached_video
  #after_commit :process_video, on: [:create]
  has_one_attached :attached_video

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :barks, as: :barkable, dependent: :destroy

  validate :content_limitations, on: %i[create update]
  #validate :validate_codec, on: %i[create update]
  validate :at_least_one_dog_selected, on: %i[create update]

  after_destroy :purge_attachments

  def aspect_ratio
    return unless attached_video.attached?
  
    blob = attached_video.blob
  
    if blob.metadata["width"].blank? || blob.metadata["height"].blank?
      blob.analyze
    end

    width = blob.metadata["width"]
    height = blob.metadata["height"]

    return unless width.present? && height.present?
  
    width.to_f / height.to_f
  end

  private

  def at_least_one_dog_selected
    errors.add(:base, "Content must be about at least one dog.") if dogs.none?
  end

  def purge_attachments
    attached_images.each(&:purge)
    attached_video.purge if attached_video.attached?
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

  # CURRENTLY UNUSED
  def process_video
    return unless attached_video.attached?

    # Download the video data and pass it to the service
    video_data = attached_video.download
    processed_path = VideoProcessingService.process(video_data)

    # Attach the processed video
    attached_video.attach(io: File.open(processed_path), filename: File.basename(processed_path))

    # Clean up the temporary file
    File.delete(processed_path) if File.exist?(processed_path)
  end

  # CURRENTLY UNUSED
  def validate_codec
    return unless attached_video.attached? && attached_video.content_type.in?(%w(video/mp4 video/webm video/ogg))

    # access tempfile from attachment
    video_tempfile = attachment_changes['attached_video'].attachable

    # use FFMPEG to analyze the video file
    movie = FFMPEG::Movie.new(video_tempfile.path)

    supported_codecs = %w(h264 avc1 vp8 vp9 theora)
    unless supported_codecs.include?(movie.video_codec)
      errors.add(:attached_video, "must be encoded with a supported codec (H.264, VP8, VP9, or Theora). Current codec is #{movie.video_codec}.")
    end
  end
end
