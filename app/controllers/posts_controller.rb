class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[ show edit update destroy ]

  def show
    @comments = @post.comments
  end

  def new
    @post = current_user.posts.build if current_user
  end

  def create
    @post = current_user.posts.build(post_params) if current_user

    if @post.save
      if params[:content][:dog_ids].present?
        puts "dog_id present"
        @post.dogs << Dog.where(id: params[:content][:dog_ids])
      end
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Only allow owners to edit the post
    if current_user && @post.user_id == current_user.id
      if @post.update(post_params)
        flash[:notice] = "Text post successfully edited."
        redirect_to @post
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = "You are not this post's owner."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user && @post.user_id == current_user.id
      @post.destroy
      redirect_to dogs_path, notice: 'post entry removed.'
    else
      render :edit, status: :unprocessable_entity, alert: "You are not this post's owner."
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, dog_ids: [])
  end
end
