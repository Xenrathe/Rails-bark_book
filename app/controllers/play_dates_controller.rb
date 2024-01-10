class PlayDatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_playdate, only: %i[ show edit update destroy ]

  def show
  end

  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_playdate
    @playdate = Playdate.find(params[:id])
  end

  def playdate_params
    params.require(:playdate).permit(:date, :description, :dog_park_id, :dog_size, dog_ids: [])
  end
end
