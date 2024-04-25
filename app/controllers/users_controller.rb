class UsersController < ApplicationController
  include PaginationConcern
  include LocationConcern
  helper_method :navigation_params

  before_action :authenticate_user!, except: %i[set_location]
  before_action :set_user, only: %i[show edit update make_primary destroy]

  def show
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
          distance = dog_park.address.distance_from(@location)
          [dog_park, distance]
        end.sort_by(&:last)
      end

      @owned_dogs = @user.dogs
      @followed_dogs = @user.followed_dogs.includes(avatar_attachment: :blob)

      @new_address = current_user.addresses.build if @user.id == current_user.id
    end

    if params[:address_id].present?
      @edit_address = Address.find(params[:address_id])
    end

    contents_per_page = 2
    @user_content = @user.contents.order(created_at: :desc).limit(contents_per_page).offset((@page - 1) * contents_per_page).includes(attached_images_attachments: :blob)
    @comments = Comment.where(commentable_type: 'Content').where(commentable_id: @user_content )
    @comments_counts = @comments.group(:commentable_id).count
    @barks = Bark.where(barkable_type: 'Content').where(barkable_id: @user_content)
    @barks_counts = @barks.group(:barkable_id).count
    @barks_sums = @barks.group(:barkable_id).sum(:num)

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
    # Only allow users to change their own data
    if current_user && current_user == @user
      if @user.update(user_params)
        flash[:notice] = "User successfully edited."
        redirect_to @user
      else
        flash[:alert] = "Error updating user: " + @user.errors.full_messages.join(", ")
        redirect_to @user
      end
    else
      flash[:alert] = "You cannot edit other user's profiles."
      redirect_to @user, status: :unprocessable_entity
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

    @comments = Comment.where(commentable_type: 'Content').where(commentable_id: @feed_content)
    @comments_counts = @comments.group(:commentable_id).count
    @barks = Bark.where(barkable_type: 'Content').where(barkable_id: @feed_content)
    @barks_counts = @barks.group(:barkable_id).count
    @barks_sums = @barks.group(:barkable_id).sum(:num)

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
