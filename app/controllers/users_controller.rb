class UsersController < ApplicationController
  include PaginationConcern
  helper_method :navigation_params

  before_action :authenticate_user!, except: %i[set_location]
  before_action :set_user, only: %i[show edit update make_primary destroy]

  def show
    @followed_dog_parks = @user.followed_dog_parks
    if current_user
      @followed_dog_parks = @followed_dog_parks.sort_by do |dog_park|
        dog_park.address.distance_from(current_user.primary_address)
      end
    end

    @owned_dogs = @user.dogs
    @followed_dogs = @user.followed_dogs

    @new_address = current_user.addresses.build if @user.id == current_user.id

    if params[:address_id].present?
      @edit_address = Address.find(params[:address_id])
    end

    @user_content = Set.new
  
    @owned_dogs.each do |dog|
      @user_content.merge(dog.contents)
    end

    @user_content = @user_content.to_a
    @user_content.sort_by! { |dog_content| dog_content.created_at }.reverse!
    # Pagination
    @user_content, @total_pages = paginate_collection(@user_content, 10)
  end

  def edit
  end

  def update
    # Only allow users to change their own name
    if current_user && current_user == @user
      if @user.update(user_params)
        flash[:notice] = "User successfully edited."
        redirect_to @user
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You cannot edit other user's profiles."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @user == current_user
      @user.destroy
      redirect_to dogs_path, alert: 'Account deleted.'
    else
      render :edit, status: :unprocessable_entity, alert: 'You cannot delete other user accounts'
    end
  end

  def make_primary
    @user = User.find(params[:id])
    @address = Address.find(params[:address_id])

    if @user && @address && current_user == @user
      @user.update(primary_address: @address)
      flash[:notice] = 'Address set as primary successfully'
      redirect_back(fallback_location: root_path)
    else
      flash[:alert] = "Error updating primary address"
      render :show, status: :unprocessable_entity
    end
  end

  def new_address
    @new_address = current_user.addresses.build(address_params)

    if @new_address.save 
      current_user.update(primary_address: @new_address) if current_user.primary_address.nil?

      flash.now[:notice] = 'Created new address.'
      redirect_back(fallback_location: root_path)
    else
      flash.now[:alert] = 'Error creating new address.'
      redirect_to current_user, status: :unprocessable_entity
    end
  end

  def feed
    dogs = current_user.followed_dogs + current_user.dogs
    @feed_content = Set.new
  
    dogs.each do |dog|
      content_for_dog = dog.contents
      @feed_content.merge(content_for_dog)
    end

    current_user.followed_dog_parks.each do |dog_park|
      @feed_content.merge(dog_park.play_dates)
    end

    @feed_content = @feed_content.to_a
    @feed_content.sort_by! { |dog_content| dog_content.created_at }.reverse!
    
    # Pagination
    @feed_content, @total_pages = paginate_collection(@feed_content, 10)

    # Depending on the page / emptiness, either render the full feed view, nothing, or just the next 'page' of feed content
    if params[:page].to_i == 1 || params[:page].nil?
      render :feed
    elsif @feed_content.nil? || @feed_content.empty?
      render plain: 'Empty'
    else
      render partial: 'contents/contentfeed', locals: { feed_contents: @feed_content }
    end
  end

  def set_location
    cookies[:user_location] = {
      value: {
        latitude: params[:latitude],
        longitude: params[:longitude]
      }.to_json,
      expires: 1.hour.from_now
    }
    flash.now[:notice] = 'Location set.'
    redirect_back(fallback_location: root_path)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def address_params
    params.require(:address).permit(%i[name address_one address_two city state postal_code country addressable_type addressable_id])
  end

  def user_params
    params.require(:user).permit(:username, :time_zone, :bark_sound, :custom_bark)
  end

  def navigation_params
    params.permit(:distance, :commit)
  end

end
