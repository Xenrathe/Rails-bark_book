class PlayDate < ApplicationRecord
  include Enums

  belongs_to :dog_park
  accepts_nested_attributes_for :dog_park
  belongs_to :user
  has_and_belongs_to_many :attendees, class_name: 'Dog', join_table: 'dogs_play_dates'
  has_many :comments, as: :commentable
  has_many :barks, as: :barkable

  validate :at_least_one_dog_attendee, on: :create
  validates :date, comparison: { greater_than: DateTime.now }

  scope :upcoming, -> { where('date >= ?', DateTime.now).order(date: :asc) }

  def attend(dog)
    attendees << dog unless following?(dog)
  end

  def unattend(dog)
    attendees.delete(dog)
  end

  def following?(dog)
    attendees.include?(dog)
  end

  private

  def at_least_one_dog_attendee
    if attendees.none?
      errors.add(:base, "At least one dog attendee must be selected")
    end
  end

end
