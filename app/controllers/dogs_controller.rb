class DogsController < ApplicationController
  include PaginationConcern
  include LocationConcern
  helper_method :navigation_params
  
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_dog, only: %i[ show edit update destroy follow unfollow ]

  def index
    # filter by distance
    distance = params[:distance].present? ? params[:distance] : '25'
    if distance != 'all'
      location = get_location(current_user)
      if location
        @dogs = Dog.includes(avatar_attachment: :blob).nearby(location, distance.to_i)
      else
        @dogs = Dog.includes(avatar_attachment: :blob).all
      end
    else
      @dogs = Dog.includes(avatar_attachment: :blob).all
    end

    # filter by breed name
    breed = params[:breed]
    @dogs = @dogs.where('LOWER(breed) LIKE ?', "%#{breed.downcase}%") if breed.present?

    # Pagination
    @dogs, @total_pages = paginate_collection(@dogs, 10)

    # Load up current user's followed dogs or make nil
    @followed_dogs = current_user&.followed_dogs.to_a
  end

  def show
    @bark_count = @dog.barks.sum(:num)
    @bark_user_count = @dog.barks.count
    @did_user_bark = @dog.barks.where(user: current_user).exists?
    @dog_feed = @dog.contents.to_a.sort_by!(&:created_at).reverse!

    @dog_feed, @total_pages = paginate_collection(@dog_feed, 10)
  end

  def new
    @dog = current_user.dogs.build if current_user
  end

  def create
    @dog = current_user.dogs.build(dog_params) if current_user
    @dog.save

    if @dog.save
      redirect_to @dog
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Only allow owners to edit the dog
    if current_user && @dog.user_id == current_user.id
      if @dog.update(dog_params)
        flash[:notice] = "Dog successfully edited."
        redirect_to @dog
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You are not this dog's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @dog.user_id == current_user.id
      @dog.destroy
      redirect_to dogs_path, notice: 'Dog entry removed.'
    else
      render :edit, status: :unprocessable_entity, alert: "You are not this dog's owner."
    end
  end

  def follow
    current_user.follow(@dog)
    flash.now[:notice] = 'Now following the dog!'
    redirect_back(fallback_location: root_path)
  end
  
  def unfollow
    current_user.unfollow(@dog)
    flash.now[:notice] = 'Unfollowed the dog.'
    redirect_back(fallback_location: root_path)
  end

  private

  def set_dog
    @dog = Dog.find(params[:id])
  end

  def dog_params
    params.require(:dog).permit(:avatar, :birthdate, :breed, :name, :weight)
  end

  def navigation_params
    params.permit(:distance, :breed, :page, :commit)
  end
end
