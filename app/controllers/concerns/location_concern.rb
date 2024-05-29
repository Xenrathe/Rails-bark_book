module LocationConcern
  extend ActiveSupport::Concern
  require 'ipaddr'

  def get_location(user)
    location_cookie = cookies[:user_location]
  
    # Priority is to return browser location API
    # ELSE return user's primary address (which should be geocoded)
    # ELSE return IP
    if location_cookie.present?
      location_data = JSON.parse(location_cookie)
      location = [location_data['latitude'], location_data['longitude']]
    elsif user&.primary_address
      location = user.primary_address
    else
      # Retrieve the IP address from the Fly-Client-IP header
      fly_client_ip = request.headers['HTTP_FLY_CLIENT_IP']
      remote_ip = fly_client_ip || request.remote_ip
      ip_address = IPAddr.new(remote_ip) rescue nil
  
      # Ensure we have a valid IP address
      if ip_address
        if ip_address.ipv4?
          proper_ip = remote_ip
        elsif ip_address.ipv6?
          if ip_address.ipv4_mapped? # Handle IPv4-mapped IPv6 addresses
            proper_ip = ip_address.native.to_s
          else
            proper_ip = remote_ip # Return the IPv6 address as-is if not IPv4-mapped
          end
        else
          proper_ip = nil
        end
      else
        proper_ip = nil
      end
  
      puts "PROPER IP: #{proper_ip}"
      
      location = proper_ip
    end

    update_user_loc(user, location)
    location
  end

  # This alters the user's latitude and longitude, which are used to represent their dog's location
  def update_user_loc(user, location)
    return unless user
    return if user.primary_address # Default for finding dog is primary_address
    return unless user.location_permission # This defaults to FALSE - users must OPT IN (or add a primary address)

    if location.is_a?(Array) # JavaScript 'navigator' location API
      user.update(latitude: location[0], longitude: location[1])
    elsif user.latitude.nil? # IP ADDRESS - only do if nil already, don't want to geocode every single time
      results = Geocoder.search(location)
      user.update(latitude: results.first.coordinates[0], longitude: results.first.coordinates[1]) unless results.nil?
    end
  end
end
