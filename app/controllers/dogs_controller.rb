class DogsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_dog, only: %i[ show edit update destroy ]

  # GET /dogs or /dogs.json
  def index
    @dogs = Dog.all
  end

  def show
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
      flash[:notice] = "Dog entry removed."
      redirect_to dogs_path
    else
      flash[:alert] = "You are not this dog's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_dog
    @dog = Dog.find(params[:id])
  end

  def dog_params
    params.require(:dog).permit(:avatar, :birthdate, :breed, :name, :weight)
  end
end
