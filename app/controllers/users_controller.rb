class UsersController < ApplicationController

  layout :resolve_layout
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to contacts_path, notice: "Welcome to the addresbook portal"
    else
      render :new
    end

  end

 
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def resolve_layout
    case action_name
    when "new", "create"
      "auth"
    else
      "application"
    end
  end
end
