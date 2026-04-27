class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :change_password, :update_password  ]
  attr
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

  def change_password
  end

  def update_password
    if @user.authenticate(params[:user][:current_password])
      if @user.update(user_params)
        redirect_to user_path(@user), notice: "Password successfully updated!"
      else
        render :change_password, status: :unprocessable_entity
      end
    else
      @user.errors.add(:current_password, "is incorrect")
      render :change_password, status: :unprocessable_entity
    end
  end


  def update
    # Standard profile update (username, etc.)
    if @user.update(user_params.except(:password, :password_confirmation))
      redirect_to user_path(@user), notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end



  def show
  end

  def edit
  end


 private

 def set_user
  @user = current_user
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
