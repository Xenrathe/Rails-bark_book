class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  def self.find_existing(attributes)
    find_by(
      'lower(address_one) = ? AND lower(city) = ? AND
       lower(state) = ? AND lower(country) = ? AND lower(postal_code) = ?',
      attributes[:address_one].downcase,
      attributes[:city].downcase,
      attributes[:state].downcase,
      attributes[:country].downcase,
      attributes[:postal_code].downcase
    )
  end
end
