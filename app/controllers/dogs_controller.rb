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
    @page = params[:page].present? ? params[:page].to_i : 1

    contents_per_page = 10
    @dog_feed = @dog.contents.order(created_at: :desc).limit(contents_per_page).offset((@page - 1) * contents_per_page).includes(attached_images_attachments: :blob)

    # If necessary, pre-load all these database queries
    unless @dog_feed.nil? || @dog_feed.empty?
      @comments = Comment.where(commentable_type: 'Content').where(commentable_id: @dog_feed )
      @comments_counts = @comments.group(:commentable_id).count
      @barks = Bark.where(barkable_type: 'Content').where(barkable_id: @dog_feed)
      @barks_counts = @barks.group(:barkable_id).count
      @barks_sums = @barks.group(:barkable_id).sum(:num)
    end

    # Depending on the page / emptiness, either render the full feed view, nothing, or just the next 'page' of feed content
    if @page == 1
      render :show
    elsif @dog_feed.nil? || @dog_feed.empty?
      render plain: 'Empty'
    else
      render partial: 'contents/contentfeed', locals: { feed_contents: @dog_feed }
    end
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
    params.permit(:distance, :breed, :commit)
  end
end
