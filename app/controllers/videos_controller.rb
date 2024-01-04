class VideosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_video, only: %i[ show edit update destroy ]

  def show
    @comments = @video.comments
  end

  def new
    @video = current_user.videos.build if current_user
  end

  def create
    @video = current_user.videos.build(video_params) if current_user

    if @video.save
      if params[:content][:dog_ids].present?
        puts "dog_id present"
        @video.dogs << Dog.where(id: params[:content][:dog_ids])
      end
      redirect_to @video
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Only allow owners to edit the video
    if current_user && @video.user_id == current_user.id
      if @video.update(video_params)
        flash[:notice] = "Video post successfully edited."
        redirect_to @video
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You are not this post's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @video.user_id == current_user.id
      @video.destroy
      redirect_to dogs_path, notice: 'Video entry removed.'
    else
      render :edit, status: :unprocessable_entity, alert: "You are not this post's owner."
    end
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:title, :caption, :attached_video , dog_ids: [])
  end
end
