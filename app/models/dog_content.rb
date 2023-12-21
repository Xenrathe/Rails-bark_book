class DogContent < ApplicationRecord
  belongs_to :dog
  belongs_to :content, polymorphic: true
end
