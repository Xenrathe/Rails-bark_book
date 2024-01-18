class DogParksController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_dogpark, only: %i[show edit update destroy follow unfollow]

  def show
    @upcoming_play_dates = @dog_park.play_dates.upcoming
  end

  def index
    @dog_parks = DogPark.all
  end

  def new
    @dog_park = DogPark.new
    @dog_park.build_address
  end

  def create
    @dog_park = DogPark.new(dog_park_params)
    existing_address = Address.find_existing(params[:dog_park][:address_attributes])

    if existing_address && existing_address.addressable_type == 'DogPark'
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
    params.require(:dog_park).permit(:name, :dog_size, address_attributes:
      %i[address_one address_two city state postal_code country])
  end
end
