class UsersController < ApplicationController
  include PaginationConcern
  include LocationConcern
  helper_method :navigation_params

  before_action :authenticate_user!, except: %i[set_location]
  before_action :set_user, only: %i[show edit update make_primary destroy]
  before_action :reset_flash, only: %i[feed]

  def show

    if params[:mode].present?
      @mode = params[:mode]
    end

    @page = params[:page].present? ? params[:page].to_i : 1
    # Only load up all of this information if the page is being rendered for the first time
    if @page == 1
      @user = User.includes(followed_dog_parks: :address, dogs: [{ avatar_attachment: :blob }]).find(params[:id])

      #Load up the followed_dog_parks to reduce queries to database
      @followed_dog_parks = current_user&.followed_dog_parks.to_a
      @user_dog_parks = @user.followed_dog_parks.to_a
      if current_user
        @location = get_location(current_user)
        @user_dog_parks = @user_dog_parks.map do |dog_park|
          begin
            distance = dog_park.address.distance_from(@location) # Will return nil if dog_park.address geocoding failed
            distance = nil if distance.nan? # Will return NaN in certain situations
          rescue NoMethodError
            distance = nil # This situation occurs if the @location geocoding fails
          end
          [dog_park, distance]
        end.sort_by { |_, distance| distance || Float::INFINITY } # To account for NIL values
      end

      @owned_dogs = @user.dogs
      @followed_dogs = @user.followed_dogs.includes(avatar_attachment: :blob)

      @new_address = current_user.addresses.build if @user.id == current_user.id
    end

    if params[:address_id].present?
      @edit_address = Address.find(params[:address_id])
    end

    contents_per_page = 10
    @user_content = @user.contents.order(created_at: :desc).limit(contents_per_page).offset((@page - 1) * contents_per_page).includes(attached_images_attachments: :blob)
    
    # If necessary, pre-load all these database queries
    unless @user_content.nil? || @user_content.empty?
      @comments = Comment.where(commentable_type: 'Content').where(commentable_id: @user_content )
      @comments_counts = @comments.group(:commentable_id).count
      @barks = Bark.where(barkable_type: 'Content').where(barkable_id: @user_content)
      @barks_counts = @barks.group(:barkable_id).count
      @barks_sums = @barks.group(:barkable_id).sum(:num)
    end

    # Depending on the page / emptiness, either render the full feed view, nothing, or just the next 'page' of feed content
    if @page == 1
      render :show
    elsif @user_content.nil? || @user_content.empty?
      render plain: 'Empty'
    else
      render partial: 'contents/contentfeed', locals: { feed_contents: @user_content }
    end
  end

  def edit
  end

  def update
    # User#show view (which is where user#update is called) has multiple error displays/update buttons
    # So we need to determine under WHICH button to display the error
    if params[:user][:location_permission].present?
      @mode = 'permission'
    elsif params[:user][:username].present? || params[:user][:time_zone].present?
      @mode = 'personal'
    elsif params[:user][:bark_sound].present?
      @mode = 'bark'
    end

    # Only allow users to change their own data
    if current_user && current_user == @user
      if @user.update(user_params)
        if @mode == 'permission'
          if @user.location_permission
            if @user.primary_address
              @user.update(latitude: @user.primary_address.latitude, longitude: @user.primary_address.longitude )
            else
              flash[:location_request] = true #trigger a navigator browser request
              get_location(current_user)
            end
          else
            @user.update(latitude: nil, longitude: nil)
          end
        end
        
        flash[:notice] = "User successfully edited."
        redirect_to user_path(@user, mode: @mode)
      else
        flash[:alert] = "Error updating user: " + @user.errors.full_messages.join(", ")
        redirect_to user_path(@user, mode: @mode)
      end
    else
      flash[:alert] = "You cannot edit other user's profiles."
      redirect_to user_path(@user, status: :unprocessable_entity, mode: @mode)
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

      if @address.latitude.nil?
        @user.update(primary_address: @address)
      else
        @user.update(primary_address: @address, longitude: @address.longitude, latitude: @address.latitude)
      end

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

      if current_user.primary_address.nil?
        if @new_address.latitude.nil?
          current_user.update(primary_address: @new_address)
        else
          current_user.update(primary_address: @new_address, latitude: @new_address.latitude, longitude: @new_address.longitude)
        end
      end

      flash.now[:notice] = 'Created new address.'
      redirect_back(fallback_location: root_path)
    else
      flash.now[:alert] = 'Error creating new address.'
      redirect_to current_user, status: :unprocessable_entity
    end
  end

  def feed
    @location = get_location(current_user)

    # I use the .to_a to force the query to run
    # Otherwise, the @comments, etc block ends up running first, which doubles query time
    # Probably a more elegant way to do it
    @page = params[:page].present? ? params[:page].to_i : 1
    contents_per_page = 10
    @followed_dogs = current_user.followed_dogs
    @feed_content = Content.joins(:dogs).where(dogs: @followed_dogs)
                            .or(Content.where(user: current_user))
                            .order(created_at: :desc)
                            .limit(contents_per_page)
                            .offset((@page - 1) * contents_per_page)
                            .includes(attached_images_attachments: :blob).to_a #see? forced into memory

    # If necessary, pre-load all these database queries
    unless @feed_content.nil? || @feed_content.empty?
      @comments = Comment.where(commentable_type: 'Content').where(commentable_id: @feed_content)
      @comments_counts = @comments.group(:commentable_id).count
      @barks = Bark.where(barkable_type: 'Content').where(barkable_id: @feed_content)
      @barks_counts = @barks.group(:barkable_id).count
      @barks_sums = @barks.group(:barkable_id).sum(:num)
    end

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

  def reset_flash
    flash.clear
  end

  def address_params
    params.require(:address).permit(%i[name address_one address_two city state postal_code country addressable_type addressable_id])
  end

  def user_params
    params.require(:user).permit(:username, :time_zone, :bark_sound, :custom_bark, :location_permission)
  end

  def navigation_params
    params.permit(:distance, :commit)
  end

end
