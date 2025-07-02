# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  include LocationConcern
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    # A hidden honeypot field to catch bots
    if params[:nickname].present?
      BotTrapLog.create!(
        ip: get_properIP,
        user_agent: request.user_agent,
        reason: "pwreset honeypot",
        metadata: {
          email: params[:user][:email]
        }
      )
      flash[:notice] = "If this email address is linked to an account, an email with instructions will arrive in a few minutes."
      redirect_to new_session_path(resource_name) and return
    end

    #check if user email actually exists
    user = resource_class.find_by(email: params[resource_name][:email])

    if user
      super
      flash[:notice] = "If this email address is linked to an account, an email with instructions will arrive in a few minutes."
    else
      BotTrapLog.create!(
        ip: get_properIP,
        user_agent: request.user_agent,
        reason: "pwreset non-existent email",
        metadata: {
          email: params[:user][:email]
        }
      )
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
