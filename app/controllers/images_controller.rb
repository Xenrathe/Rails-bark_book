class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[ show edit update destroy ]

  def show
    @comments = @image.comments
  end

  def new
    @image = current_user.images.build if current_user
  end

  def create
    @image = current_user.images.build(image_params) if current_user

    if @image.save
      if params[:content][:dog_ids].present?
        puts "dog_id present"
        @image.dogs << Dog.where(id: params[:content][:dog_ids])
      end
      redirect_to @image
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Only allow owners to edit the image
    if current_user && @image.user_id == current_user.id
      if @image.update(image_params)
        flash[:notice] = "Image post successfully edited."
        redirect_to @image
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You are not this post's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @image.user_id == current_user.id
      @image.destroy
      redirect_to dogs_path, notice: 'Image entry removed.'
    else
      render :edit, status: :unprocessable_entity, alert: "You are not this post's owner."
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :caption, attached_images: [], dog_ids: [])
  end

end
