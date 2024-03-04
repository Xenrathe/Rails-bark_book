class PlayDatesController < ApplicationController
  include PaginationConcern
  helper_method :navigation_params

  before_action :authenticate_user!
  before_action :set_playdate, only: %i[ show edit update destroy attend ]

  def show
    @barks = @play_date.barks
  end

  def index
    distance = params[:distance].present? ? params[:distance] : '25'

    # filter by distance
    if distance != 'all' && current_user && current_user.primary_address
      nearby_playdates = PlayDate.nearby(current_user, distance.to_i) # Returns an array
      @play_dates = PlayDate.where(id: nearby_playdates.pluck(:id)) # Convert back to relation... inefficient?
    else
      @play_dates = PlayDate.upcoming
    end

    @play_dates, @total_pages = paginate_collection(@play_dates, 10)
  end

  def new
    @play_date = PlayDate.new(dog_size: 'both')
    @play_date.build_dog_park
    @play_date.dog_park.build_address
  end

  def create
    @play_date = PlayDate.new
    @play_date.date = params[:play_date][:date]
    @play_date.description = params[:play_date][:description]
    @play_date.dog_size = params[:play_date][:dog_size]
    @play_date.user_id = current_user.id

    # if user decides to use a pre-existing dog_park
    if params[:play_date][:dog_park_id].present? && params[:play_date][:dog_park_id] != 'new'
      @dog_park = DogPark.find(params[:play_date][:dog_park_id])
      @play_date.dog_park = @dog_park
    else # or the user decides to create a new dog_park
      if params[:play_date][:dog_park].present? && params[:play_date][:dog_park][:address_attributes].present?
        existing_address = Address.find_existing(params[:play_date][:dog_park][:address_attributes])
      else
        flash.now[:alert] = 'Must choose a dog park or create a new one.'
        render :new, status: :unprocessable_entity
        return
      end

      # but wait! that dog park already exists!
      if existing_address && existing_address.addressable_type == 'DogPark'
        @dog_park = DogPark.find(existing_address.addressable_id)
        @play_date.dog_park = @dog_park
      end
    end

    if params[:play_date][:dog_attendee_ids].present?
      params[:play_date][:dog_attendee_ids].each do |dog_attendee_id|
        @play_date.attend(Dog.find(dog_attendee_id))
      end
    end

    if @play_date.save
      flash[:notice] = 'Play Date was successfully created.'
      current_user.follow(@play_date.dog_park)
      redirect_to @play_date
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
    if current_user && @play_date.user_id == current_user.id
      if @play_date.attendees.all? { |dog| dog.user == current_user }
        @play_date.destroy
        redirect_to play_dates_url, notice: 'Play date removed.'
      else
        flash.now[:alert] = 'Cannot remove play-dates with other dogs.'
        render :show, status: :unprocessable_entity, alert: "Cannot remove play-dates with other people's dogs."
      end
    else
      render :show, status: :unprocessable_entity, alert: "You are not this play-date's owner."
    end
  end

  # The expectation with this function is that a user will select their dogs
  # then press an 'attend' button,
  # meaning those selecting should ATTEND, while those unselected should UNATTEND
  def attend
    current_user.dogs.each do |user_dog|
      if params[:dog_attendee_ids].present? && params[:dog_attendee_ids].include?(user_dog.id.to_s)
        @play_date.attend(user_dog)
      elsif params[:play_date].present? && params[:play_date][:dog_attendee_ids].present? && params[:play_date][:dog_attendee_ids].to_i.include?(user_dog.id)
        @play_date.attend(user_dog)
      else
        @play_date.unattend(user_dog)
      end
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def set_playdate
    @play_date = PlayDate.find(params[:id])
  end

  def play_date_params
    params.require(:play_date).permit(:date, :description, :dog_park_id, :dog_size, dog_attendee_ids: [],
      dog_park_attributes: [:id, :name, :dog_size, 
        address_attributes: %i[address_one address_two city state postal_code country]
      ]
    )
  end

  def navigation_params
    params.permit(:distance, :commit)
  end
end
