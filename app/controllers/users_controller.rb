class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @followed_dogs = @user.followed_dogs
  end
end
