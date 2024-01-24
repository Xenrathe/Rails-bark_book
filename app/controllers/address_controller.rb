class AddressController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address

  def update
    # Only admins will be able to update DogPark addresses
    # And users can only edit their own addresses
    if @address.addressable_type == 'User' && current_user && current_user.id == @address.addressable_id
      if @address.update(address_params)
        flash.now[:notice] = 'Address successfully edited.'
      else
        flash.now[:alert] = 'Error editing address.'
      end
      redirect_back(fallback_location: root_path)
    else
      flash.now[:alert] = 'Error editing address.'
      redirect_back(fallback_location: root_path, status: :unprocessable_entity)
    end
  end

  def destroy
    if current_user && @address.addressable_type == 'User' && @address.addressable_id == current_user.id
      @address.destroy
      flash.now[:notice] = 'Address successfully removed.'
    else
      flash.now[:alert] = 'Error removing address.'
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def set_address
    @address = Address.find(params[:id])
  end

  def address_params
    params.require(:address).permit(%i[name address_one address_two city state postal_code country addressable_type addressable_id])
  end
end
