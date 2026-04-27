# class PasswordResetsController < ApplicationController

#   layout "auth"

#   def new

#   end


#   def create
#     user = User.find_by(email: params[:email].downcase)

#   if user
#   user.generate_password_token!
#   UserMailer.forgot_password(user).deliver_now
#   redirect_to root_path, notice: "Check your email for password reset instructions."
#   else
#   flash.now[:alert] = "Email address not found."
#   render :new, status: :not_found
#   end
#   end



#   def edit
#     @token = params[:token]
#   end



#   def update
#     token = params[:token].to_s
#     user = User.find_by(reset_password_token: token)

#     if user.present? && user.password_token_valid?
#       if user.reset_password!(params[:password])
#       redirect_to root_path, notice: "Password updated successfully!"

#       else
#         flash.now[:alert] = user.errors.full_messages.to_sentence
#         render :edit, status: :unprocessable_entity

#       end
#     else

#       redirect_to new_password_reset_path, alert: "Link expired."

#     end
#   end
# end

class PasswordResetsController < ApplicationController
  layout "auth"

  # 1. Add the before_action at the top
  before_action :set_user, only: [ :edit, :update ]

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user
      user.generate_password_token!
      UserMailer.forgot_password(user).deliver_now
      redirect_to root_path, notice: "Check your email for password reset instructions."
    else
      flash.now[:alert] = "Email address not found."
      render :new, status: :not_found
    end
  end

  def edit
    # We no longer need code here! set_user handles it.
  end

  def update
    if @user.password_token_valid?
      if @user.reset_password!(params[:password])
        redirect_to root_path, notice: "Password updated successfully!"
      else
        # If validations fail, @user.errors will be sent to the view
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to new_password_reset_path, alert: "Link expired. Please try again."
    end
  end

  private

  # 2. Define the private method to find the user
  def set_user
    @user = User.find_by(reset_password_token: params[:token])

    # If the token is fake or expired, stop them immediately
    if @user.blank?
      redirect_to new_password_reset_path, alert: "Link invalid or expired."
    end
  end
end
