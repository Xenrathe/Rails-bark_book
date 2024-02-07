class DogsController < ApplicationController
  include PaginationConcern
  helper_method :navigation_params
  
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_dog, only: %i[ show edit update destroy follow unfollow ]

  def index
    distance = params[:distance].present? ? params[:distance] : '25'

    if distance != 'all' && current_user && current_user.primary_address
      @dogs = Dog.nearby(current_user, distance.to_i)
    else
      @dogs = Dog.all
    end

    # Pagination
    @dogs, @total_pages = paginate_collection(@dogs, 10)
    puts "@dogs size is #{@dogs.count}"
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
    params.permit(:distance, :commit)
  end
end
