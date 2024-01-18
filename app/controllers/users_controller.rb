class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update make_primary destroy]

  def show
    @followed_dogs = @user.followed_dogs
    @owned_dogs = @user.dogs
    @followed_dog_parks = @user.followed_dog_parks

    @new_address = current_user.addresses.build if @user.id == current_user.id

    @user_content = Set.new
  
    @owned_dogs.each do |dog|
      @user_content.merge(dog.contents)
    end

    @user_content = @user_content.to_a
    @user_content.sort_by! { |dog_content| dog_content.created_at }.reverse!
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
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def address_params
    params.require(:address).permit(%i[name address_one address_two city state postal_code country addressable_type addressable_id])
  end

  def user_params
    params.require(:user).permit(:username, :time_zone)
  end

end
