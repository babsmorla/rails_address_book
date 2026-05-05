class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :change_password, :update_password  ]
  attr
  layout :resolve_layout


  def new
    @user = User.new
  end

 def create
  # Use .dig to safely check for the role code in the flat structure f.select creates
  role_provided = params.dig(:user, :admin_role_code)

  if current_user&.admin? && role_provided.present?
    # Admin is allowed to pass the role_code through user_params
    @user = User.new(user_params)
  else
    # Regular signup or missing role: strip the role_code and force 'usr'
    @user = User.new(user_params.except(:admin_role_code))
    @user.admin_role_code = "usr"
  end

  if @user.save
    if current_user&.admin?
      redirect_to admins_path, notice: "User created successfully"
    else
      # status: :see_other is required for Turbo redirects after a POST
      redirect_to new_session_path, notice: "Account created successfully. Please log in.", status: :see_other
    end
  else
    render :new, status: :unprocessable_entity
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
