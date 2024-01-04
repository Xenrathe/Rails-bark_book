class DogContent < ApplicationRecord
  belongs_to :dog
  belongs_to :content, polymorphic: true

  scope :recent, -> { order('contents.created_at DESC') }
end
