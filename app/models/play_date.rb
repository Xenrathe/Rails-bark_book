class PlayDate < ApplicationRecord
  include Enums
  
  belongs_to :dog_park
  accepts_nested_attributes_for :dog_park
  belongs_to :user
  has_and_belongs_to_many :attendees, class_name: 'Dog', join_table: 'dogs_play_dates'
  has_many :comments, as: :commentable
  has_many :barks, as: :barkable

  scope :upcoming, -> { where('date >= ?', DateTime.now).order(date: :asc) }
end
