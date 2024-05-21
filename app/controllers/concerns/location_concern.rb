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
      [location_data['latitude'], location_data['longitude']]
    elsif user&.primary_address
      user.primary_address
    else
      # Retrieve the IP address from the Fly-Client-IP header
      fly_client_ip = request.headers['HTTP_FLY_CLIENT_IP']
      remote_ip = fly_client_ip || request.remote_ip
      ip_address = IPAddr.new(remote_ip) rescue nil

      # Ensure we have a valid IP address
      if ip_address
        # Convert IPv6 to IPv4 if necessary
        if ip_address.ipv4?
          proper_ip = remote_ip
        elsif ip_address.ipv6? && ip_address.ipv4_mapped?
          proper_ip = ip_address.native.to_s
        else
          proper_ip = nil
        end
      else
        proper_ip = nil
      end

      puts "REMOTE IP: #{remote_ip}"
      puts "FLY CLIENT IP: #{fly_client_ip}"
      puts "IP ADDRESS: #{ip_address.inspect}"
      puts "PROPER IP: #{proper_ip}"

      proper_ip
    end
  end
end
