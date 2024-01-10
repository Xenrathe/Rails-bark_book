class Bark < ApplicationRecord
  belongs_to :user
  belongs_to :barkable, polymorphic: true

  validates :num, numericality: { less_than: 51 }
end
