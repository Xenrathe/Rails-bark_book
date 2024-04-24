class DogParksController < ApplicationController
  include PaginationConcern
  include LocationConcern
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_dogpark, only: %i[edit update destroy follow unfollow] # show action uses a modified version

  def show
    @dog_park = DogPark.includes(attached_images_attachments: :blob).find(params[:id])
    @upcoming_play_dates = @dog_park.play_dates.upcoming.limit(10)
    @attendee_counts = @upcoming_play_dates.joins(:attendees).group('play_dates.id').count
    @comments = @dog_park.comments.includes(:user)
    @location = get_location(current_user)

    # Used for the image gallery
    @attached_images, @total_pages = paginate_collection(@dog_park.attached_images, 3)
  end

  def index
    distance = params[:distance].present? ? params[:distance] : '25'
    
    #LOCATIONATE!
    location = get_location(current_user)
    if location
      @nearby_dog_parks = DogPark.nearby(location, distance.to_i)
    else
      @nearby_dog_parks = []
    end

    #PAGINATE!
    @nearby_dog_parks, @total_pages = paginate_collection(@nearby_dog_parks, 10)

    #Also load up the followed_dog_parks to reduce queries to database
    @followed_dog_parks = current_user&.followed_dog_parks.to_a
  end

  def new
    @dog_park = DogPark.new
    @dog_park.build_address
  end

  def create
    @dog_park = DogPark.new(dog_park_params)
    existing_address = @dog_park.address.find_existing

    if !existing_address.empty? && existing_address.first.addressable_type == 'DogPark'
      flash.now[:alert] = 'This dog park already exists.'
      render :new, status: :unprocessable_entity
    else
      @dog_park = DogPark.new(dog_park_params)
      @dog_park.address.name = @dog_park.name

      if @dog_park.save
        flash[:notice] = 'Dog Park was successfully created.'
        current_user.follow(@dog_park)
        redirect_to @dog_park
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    # Eventually allow admins to edit but for now only users can upload images
    if current_user
      if params[:dog_park][:attached_images].present?
        params[:dog_park][:attached_images].each do |image|
          @dog_park.attached_images.attach(image)
        end

        if @dog_park.valid?
          flash[:notice] = "Images successfully added."
          redirect_back(fallback_location: root_path)
        else
          flash[:alert] = "Error adding images: " + @dog_park.errors.full_messages.join(", ")
          redirect_back(fallback_location: root_path, status: :unprocessable_entity)
        end
      else
        flash[:alert] = "Error adding images"
        redirect_back(fallback_location: root_path, status: :unprocessable_entity)
      end
    else
      flash[:alert] = "Must be logged in to post images."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  def follow
    current_user.follow(@dog_park)
    flash.now[:notice] = 'Now following the dog park!'
    redirect_back(fallback_location: root_path)
  end
  
  def unfollow
    current_user.unfollow(@dog_park)
    flash.now[:notice] = 'Unfollowed the dog park.'
    redirect_back(fallback_location: root_path)
  end

  private

  def set_dogpark
    @dog_park = DogPark.find(params[:id])
  end

  def dog_park_params
    params.require(:dog_park).permit(:name, :dog_size, attached_images: [], address_attributes:
      %i[address_one address_two city state postal_code country])
  end

  def dog_park_image_params
    params.require(:dog_park).permit(attached_images: [])
  end
end
