class PlayDatesController < ApplicationController
  include LocationConcern
  helper_method :navigation_params

  before_action :authenticate_user!, except: %i[show index]
  before_action :set_playdate, only: %i[edit update destroy attend]
  before_action :load_dogs, only: %i[show index new]
  before_action :reset_flash, only: %i[show index]

  def show
    @play_date = PlayDate.includes(:dog_park, attendees: [:user, { avatar_attachment: :blob }]).find(params[:id])
    @barks = @play_date.barks
    @comments = @play_date.comments.includes(:user)
    @location = get_location(current_user)
  end

  def index
    # filter by tracked
    tracked_only = params[:tracked].present? ? params[:tracked] : 'all'
    if tracked_only == 'tracked' && current_user
      @play_dates = PlayDate.where(dog_park_id: current_user.followed_dog_parks).upcoming
    else
      @play_dates = PlayDate.all.upcoming
    end

    # filter by distance
    distance = params[:distance].present? ? params[:distance] : '25'
    @location = get_location(current_user)
    if distance != 'all' && @location
      @play_dates = @play_dates.nearby(@location, distance.to_i)
    end

    # paginate
    @page = params[:page].present? ? params[:page].to_i : 1
    per_page = 10
    @play_dates = @play_dates.limit(per_page).offset((@page - 1) * per_page).includes(:barks, dog_park: :address, comments: :user, attendees: { avatar_attachment: :blob })
    @comments = Comment.where(commentable_type: 'PlayDate').where(commentable_id: @play_dates )
    @comments_counts = @comments.group(:commentable_id).count
    @barks = Bark.where(barkable_type: 'PlayDate').where(barkable_id: @play_dates)
    @barks_counts = @barks.group(:barkable_id).count
    @barks_sums = @barks.group(:barkable_id).sum(:num)

    # Depending on the page / emptiness, either render the full index view, nothing, or just the next 'page' of play-dates
    if @page == 1
      render :index
    elsif @play_dates.nil? || @play_dates.empty?
      render plain: 'Empty'
    else
      render partial: '/play_dates/indexpage'
    end
  end

  def new
    @play_date = PlayDate.new(dog_size: 'both')
    @play_date.build_dog_park
    @play_date.dog_park.build_address
  end

  def create
    @play_date = PlayDate.new(play_date_params)
    @play_date.user_id = current_user.id

    # if user decides to use a pre-existing dog_park
    if params[:play_date][:dog_park_id].present? && params[:play_date][:dog_park_id] != 'new'
      @dog_park = DogPark.find(params[:play_date][:dog_park_id])
      @play_date.dog_park = @dog_park
    else # or the user decides to create a new dog_park
      if params[:play_date][:dog_park_attributes].present? && params[:play_date][:dog_park_attributes][:address_attributes].present?
        @play_date.dog_park.address.name = @play_date.dog_park.name # Form doesn't have space for address name but name IS required
        existing_address = @play_date.dog_park.address.find_existing
      else
        flash.now[:alert] = 'Must choose a dog park or create a new one.'
        render :new, status: :unprocessable_entity
        return
      end

      # but wait! that dog park already exists!
      if !existing_address.empty? && existing_address.first.addressable_type == 'DogPark'
        @dog_park = DogPark.find(existing_address.addressable_id)
        @play_date.dog_park = @dog_park
      end
    end

    # dog attendance
    if params[:play_date][:dog_attendee_ids].present?
      params[:play_date][:dog_attendee_ids].each do |dog_attendee_id|
        @play_date.attend(Dog.find(dog_attendee_id))
      end
    end

    if @play_date.save
      current_user.follow(@play_date.dog_park)
      redirect_to @play_date
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # Note: play_date update does not have dog attendance
  # that will be changed in create and via show only
  def update
    if @play_date.update(play_date_params)
      redirect_to @play_date
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @play_date.user_id == current_user.id
      if @play_date.attendees.all? { |dog| dog.user == current_user }
        @play_date.destroy
        redirect_to play_dates_url
      else
        flash.now[:alert] = 'Cannot remove play-dates with other dogs.'
        render :show, status: :unprocessable_entity, alert: "Cannot remove play-dates with other people's dogs."
      end
    else
      render :show, status: :unprocessable_entity, alert: "You are not this play-date's owner."
    end
  end

  # this function is called for both 'attending' and 'unattending'
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
  end

  private

  def set_playdate
    @play_date = PlayDate.find(params[:id])
  end

  def reset_flash
    flash.clear
  end

  def load_dogs
    @followed_dogs = current_user&.followed_dogs.to_a
    @user_dogs = current_user&.dogs&.includes(avatar_attachment: :blob).to_a
  end

  def play_date_params
    permitted_params = params.require(:play_date).permit(:date, :description, :dog_park_id, :dog_size, dog_attendee_ids: [],
      dog_park_attributes: [:id, :name, :dog_size, 
        { address_attributes: %i[address_one address_two city state postal_code country] }
      ]
    )
    permitted_params.except(:dog_attendee_ids)
  end

  def navigation_params
    params.permit(:distance, :tracked, :commit)
  end
end
