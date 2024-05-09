class BarksController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user
      @barkable = find_barkable
      @bark = Bark.find_or_initialize_by(barkable_id: @barkable.id, barkable_type: @barkable.class.name, user_id: current_user.id)
      
      if @bark.new_record?
        @bark.num = 1
      elsif @bark.num < 50
        @bark.num += 1
      else
        return
      end

      if @bark.save
        head :no_content
        return
        #render turbo_stream: turbo_stream.replace("barks_#{@barkable.class.name}_#{@barkable.id}", partial: 'shared/barks', locals: { barks: @barkable.barks, barkable: @barkable })
      else
        head :no_content
        return
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
      elsif params[:bark][:barkable_type] == 'playdate'
        PlayDate.find(params[:bark][:barkable_id])
      end
    end
  end
end
