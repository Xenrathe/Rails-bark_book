class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  has_one :user_primary, class_name: 'User', foreign_key: 'primary_address_id', dependent: :nullify

  validates :address_one, :city, :country, :name, presence: true

  geocoded_by :full_address
  after_validation :geocode_cascading

  def full_address
    [address_one, city, state, country].compact.join(', ')
  end
  
  def find_existing
    # OLD METHOD CHECKS BASED ON STRING MATCHING
    # BUT WHAT ABOUT TYPOS OR SLIGHT CHANGES IN ADDRESS?
    #find_by(
    #  'lower(address_one) = ? AND lower(city) = ? AND lower(country) = ?',
    #  attributes[:address_one].downcase,
    #  attributes[:city].downcase,
    #  attributes[:country].downcase
    #)
    Address.near(full_address, 0.1)
  end

  def geocode_cascading
    self.latitude = nil
    self.longitude = nil

    address = Geocoder.search(full_address).first
    if address
      puts "GEOCODE ADDRESS FOUND"
      self.latitude = address.latitude
      self.longitude = address.longitude
    end

    return unless latitude.nil?

    if city.present? && state.present? && country.present?
      puts "GEOCODE CASCADING: CITY STATE"
      address = Geocoder.search("#{city}, #{state}, #{country}").first
      if address
        self.latitude = address.latitude
        self.longitude = address.longitude
      end
    end
  end
end
