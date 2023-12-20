class Bark < ApplicationRecord
  belongs_to :user
  belongs_to :barkable, polymorphic: true
end
