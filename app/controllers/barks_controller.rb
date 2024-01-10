class BarksController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user
      @barkable = find_barkable
      @bark = Bark.where(barkable_id: @barkable.id).where(barkable_type: @barkable.class.name).where(user_id: current_user.id).first
      if @barkable.nil?
        flash.now[:alert] = 'Error barking'
        head :no_content
      elsif @bark.nil? #CREATE NEW BARK IF NONE EXIST
        @bark = @barkable.barks.new(bark_params)
        @bark.user_id = current_user.id

        if @bark.save
          redirect_back(fallback_location: root_path)
        else
          flash.now[:alert] = 'Error barking'
          head :no_content
        end
      elsif @bark.num < 50 # ADD TO CURRENT BARK

        if @bark.update(num: @bark.num + 1)
          redirect_back(fallback_location: root_path)
        else
          flash.now[:alert] = 'Error barking'
          head :no_content
        end
      else
        flash.now[:alert] = 'Cannot bark more!'
        redirect_back(fallback_location: root_path)
      end
    else
      flash[:alert] = 'Must be logged in to bark'
      redirect_to new_user_session, status: :unprocessable_entity
    end
  end

  private

  def bark_params
    params.require(:bark).permit(:barkable_type, :barkable_id)
  end

  def find_barkable
    if params[:bark][:barkable_type].present? && params[:bark][:barkable_id].present?
      if params[:bark][:barkable_type] == 'content'
        Content.find(params[:bark][:barkable_id])
      elsif params[:bark][:barkable_type] == 'play_date'
        PlayDate.find(params[:bark][:barkable_id])
      end
    end
  end
end
