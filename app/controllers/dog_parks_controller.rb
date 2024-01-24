class DogParksController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_dogpark, only: %i[show edit update destroy follow unfollow]

  def show
    @upcoming_play_dates = @dog_park.play_dates.upcoming
    @comments = @dog_park.comments
  end

  def index
    distance = params[:distance].present? ? params[:distance] : '25'
    if distance != 'all'
      @nearby_dog_parks = DogPark.nearby(current_user, distance.to_i)
    else
      @nearby_dog_parks = DogPark.all
    end
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
        flash.now[:notice] = "Images successfully added."
        redirect_back(fallback_location: root_path)
      else
        flash.now[:notice] = "Error adding images"
        redirect_back(fallback_location: root_path, status: :unprocessable_entity)
      end
    else
      flash.now[:alert] = "Must be logged in to post images."
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
