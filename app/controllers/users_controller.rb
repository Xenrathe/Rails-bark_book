class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @followed_dogs = @user.followed_dogs
    @owned_dogs = @user.dogs
  end

  def feed
    dogs = current_user.followed_dogs + current_user.dogs
    @feed_content = Set.new
  
    dogs.each do |dog|
      content_for_dog = dog.contents
      @feed_content.merge(content_for_dog)
    end
  
    @feed_content = @feed_content.to_a
    @feed_content.sort_by! { |dog_content| dog_content.created_at }.reverse!
  end
end
