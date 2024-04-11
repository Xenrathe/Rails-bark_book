module LocationConcern
  extend ActiveSupport::Concern
  require 'ipaddr'

  def get_location(user)
    location_cookie = cookies[:user_location]

    # Priority is return browser location api
    # ELSE return user's primary address (which should be geocoded)
    # ELSE return IP
    if location_cookie.present?
      location_data = JSON.parse(location_cookie)
      [location_data['latitude'], location_data['longitude']]
    elsif user&.primary_address
      user.primary_address
    else
      remote_ip = request.remote_ip
      ip_address = IPAddr.new(remote_ip)
      
      # Convert IPv6 to IPv4 if necessary
      if ip_address.ipv4?
        proper_ip = remote_ip
      elsif ip_address.ipv6? && ip_address.ipv4_mapped?
        proper_ip = ip_address.ipv4_mapped.to_s
      else
        proper_ip = nil
      end
      
      puts "PROPER IP is: #{proper_ip}"
      proper_ip
    end
  end
end
