module LocationConcern
  extend ActiveSupport::Concern

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
      puts "REMOTE IP is: " + request.remote_ip
      request.remote_ip
    end
  end
end
