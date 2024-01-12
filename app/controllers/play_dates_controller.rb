class PlayDatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_playdate, only: %i[ show edit update destroy attend ]

  def show
    @barks = @play_date.barks
  end

  def index
    @play_dates = PlayDate.all
  end

  def new
    @play_date = PlayDate.new
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
      existing_address = Address.find_existing(params[:play_date][:dog_park][:address_attributes])

      # but wait! that dog park already exists!
      if existing_address && existing_address.addressable_type == 'DogPark'
        @dog_park = DogPark.find(existing_address.addressable_id)
        @play_date.dog_park = @dog_park
      end
    end

    params[:play_date][:dog_attendee_ids].each do |dog_attendee_id|
      @play_date.attend(Dog.find(dog_attendee_id))
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
end
