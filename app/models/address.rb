class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  has_one :user_primary, class_name: 'User', foreign_key: 'primary_address_id', dependent: :nullify

  validates :address_one, :city, :country, :name, presence: true

  geocoded_by :full_address
  after_validation :geocode

  def full_address
    [address_one, city, state, postal_code, country].compact.join(', ')
  end
  
  def self.find_existing(attributes)
    find_by(
      'lower(address_one) = ? AND lower(city) = ? AND lower(country) = ?',
      attributes[:address_one].downcase,
      attributes[:city].downcase,
      attributes[:country].downcase
    )
  end
end
