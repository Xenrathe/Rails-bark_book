class ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: %i[ show edit update destroy ]
  before_action :set_dogs, only: %i[new create new_post new_image new_video edit]
  before_action :reset_flash, only: %i[show]

  def show
    @comments = @content.comments.includes(:user)
    @barks = @content.barks
  end

  def new
    @content = current_user.contents.build if current_user
    @content.content_type = 'post'
  end

  def new_post
    @content = current_user.contents.build if current_user
    @content.content_type = 'post'
    render :new
  end

  def new_image
    @content = current_user.contents.build if current_user
    @content.content_type = 'image'
    render :new
  end

  def new_video
    @content = current_user.contents.build if current_user
    @content.content_type = 'video'
    render :new
  end

  def create
    @content = current_user.contents.build(content_params) if current_user

    # Validate that content_type actually matches
    if @content.content_type == 'image' && !@content.attached_images.attached?
      flash.now[:alert] = 'Image posts must contain at least one image'
      render :new, status: :unprocessable_entity
    elsif @content.content_type == 'image' && @content.attached_video.attached?
      flash.now[:alert] = 'Image posts cannot have video attachments'
      render :new, status: :unprocessable_entity
    elsif @content.content_type == 'video' && @content.attached_images.attached?
      flash.now[:alert] = 'Video posts cannot have image attachments'
      render :new, status: :unprocessable_entity
    elsif @content.content_type == 'video' && !@content.attached_video.attached?
      flash.now[:alert] = 'Video posts must have a video attachment'
      render :new, status: :unprocessable_entity
    elsif @content.content_type == 'post' && (@content.attached_images.attached? || @content.attached_video.attached?)
      flash.now[:alert] = 'Text posts cannot have attachments'
      render :new, status: :unprocessable_entity
    elsif @content.save
      redirect_to @content
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Only allow owners to edit the image
    if current_user && @content.user_id == current_user.id
      if @content.update(content_params)
        flash[:notice] = "Post successfully edited."
        redirect_to @content
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You are not this post's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @content.user_id == current_user.id
      @content.destroy
      redirect_to dogs_path, notice: 'Post removed.'
    else
      render :edit, status: :unprocessable_entity, alert: "You are not this post's owner."
    end
  end

  private

  def set_content
    # Why only includes attached_images and not attached_video? 
    # Because at most there's only one attached_video and therefore no N+1 issue will occur
    @content = Content.includes(attached_images_attachments: :blob).find(params[:id])
  end

  def reset_flash
    flash.clear
  end

  def set_dogs
    @user_dogs = current_user&.dogs&.includes(avatar_attachment: :blob)
  end

  def content_params
    params.require(:content).permit(:title, :body, :content_type, :attached_video, attached_images: [], dog_ids: [])
  end

end
