# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    # A hidden honeypot field to catch bots
    if params[:nickname].present?
      Rails.logger.info "Honeypot triggered on password reset by IP #{request.remote_ip}"
      flash[:notice] = "If this email address is linked to an account, an email with instructions will arrive in a few minutes."
      redirect_to new_session_path(resource_name) and return
    end

    #check if user email actually exists
    user = resource_class.find_by(email: params[resource_name][:email])

    if user
      super
      flash[:notice] = "If this email address is linked to an account, an email with instructions will arrive in a few minutes."
    else
      Rails.logger.info "Non-existent email request from IP #{request.remote_ip}"
      flash[:notice] = "If this email address is linked to an account, an email with instructions will arrive in a few minutes."
      redirect_to new_session_path(resource_name) and return
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
