class DogsController < ApplicationController
  before_action :set_dog, only: %i[ show edit update destroy ]

  # GET /dogs or /dogs.json
  def index
    @dogs = Dog.all
  end

  def flickr
    flickr = Flickr.new(ENV['FLICKR_API_KEY'], ENV['FLICKR_SHARED_SECRET'])
    @photos = []
  
    if params[:flickr_user_id].present?
      begin
        @photos = flickr.people.getPhotos(user_id: params[:flickr_user_id])
      rescue Flickr::FailedResponse => e
        # Log the error or print it to the console
        Rails.logger.error("Flickr API Error: #{e.message}")
  
        # Optionally, you can set a flash message to inform the user about the error
        flash[:alert] = "Failed to fetch photos from Flickr. Please try again later."
  
        # Redirect to a specific page or render an error view
        redirect_to root_path
      end
    end
    
    @photo_urls = []
    @photos.each do |photo|
      p photo
      @photo_urls << "https://live.staticflickr.com/#{photo["server"]}/#{photo["id"]}_#{photo["secret"]}.jpg"
    end
  end

  # GET /dogs/1 or /dogs/1.json
  def show
    respond_to do |format|
      format.html { redirect_to dog_url(@dog), notice: "Dog was successfully created." }
      format.json { render :show, status: :created, location: @dog }
    end
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
  end

  # POST /dogs or /dogs.json
  def create
    @dog = Dog.new(dog_params)

    respond_to do |format|
      if @dog.save
        format.html { redirect_to dog_url(@dog), notice: "Dog was successfully created." }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1 or /dogs/1.json
  def update
    respond_to do |format|
      if @dog.update(dog_params)
        format.html { redirect_to dog_url(@dog), notice: "Dog was successfully updated." }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1 or /dogs/1.json
  def destroy
    @dog.destroy

    respond_to do |format|
      format.html { redirect_to dogs_url, notice: "Dog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_dog
      @dog = Dog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dog_params
      params.require(:dog).permit(:age, :breed, :name, :weight)
    end
end
