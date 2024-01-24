class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user
      @commentable = find_commentable
      if @commentable.nil?
        flash.now[:alert] = 'Error posting comment'
        head :no_content
      else
        @comment = @commentable.comments.new(comment_params)
        @comment.user_id = current_user.id

        if @comment.save
          redirect_back(fallback_location: root_path)
        else
          flash.now[:alert] = 'Error posting comment'
          head :no_content
        end
      end
    else
      flash[:alert] = 'Must be logged in to post comments'
      redirect_to new_user_session, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :commentable_type, :commentable_id)
  end

  def find_commentable
    if params[:comment][:commentable_type].present? && params[:comment][:commentable_id].present?
      if params[:comment][:commentable_type] == 'content'
        Content.find(params[:comment][:commentable_id])
      elsif params[:comment][:commentable_type] == 'play_date'
        PlayDate.find(params[:comment][:commentable_id])
      elsif params[:comment][:commentable_type] == 'dog_park'
        DogPark.find(params[:comment][:commentable_id])
      end
    end
  end
end