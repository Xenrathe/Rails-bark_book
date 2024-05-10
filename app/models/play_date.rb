class PlayDate < ApplicationRecord
  include Enums

  belongs_to :dog_park
  accepts_nested_attributes_for :dog_park
  belongs_to :user
  has_and_belongs_to_many :attendees, class_name: 'Dog', join_table: 'dogs_play_dates'
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :barks, as: :barkable, dependent: :destroy

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

  def self.nearby(location, distance)
    return if location.nil?

    # Why this to_a in the following lines of code, you ask?
    # Because of some strange issue I couldn't quite figure out,
    # in which I had to FORCE the query to immediately load or the sorting by distance didn't work
    # Some implementation of the near function within Geocoder gem?

    if location.is_a?(Address)
      addresses = location.nearbys(distance).where(addressable_type: 'DogPark').to_a
    else
      addresses = Address.near(location, distance).where(addressable_type: 'DogPark').to_a
    end

    PlayDate.where(dog_park_id: addresses.map(&:addressable_id)).upcoming
  end

  private

  def at_least_one_dog_attendee
    if attendees.none?
      errors.add(:base, "At least one dog attendee must be selected")
    end
  end

end
