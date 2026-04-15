class SessionsController < ApplicationController

  layout "auth"

  def new
  end

  def create

  email = params[:email] || params.dig(:session, :email)
  password = params[:password] || params.dig(:session, :password)

  user = User.find_by(email: email)

  if user && user.authenticate(password)
    reset_session
    session[:user_id] = user.id 
    redirect_to contacts_path(@contacts), notice: "Logged in successfully"
  else
    flash.now[:alert] = "Invalid Email or Password" 
    render :new, status: :unprocessable_entity 
  end
end

  def destroy
    session[:user_id] = nil
    reset_session
    redirect_to new_session_path, notice: "Logged Out Succefully", status: :see_other
  end
  
end
