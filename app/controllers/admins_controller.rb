# This controller manages the admin dashboard, allowing administrators to view and manage users and contacts. It includes actions for listing users and contacts, editing user roles, and deleting users. The dashboard is protected by an admin-only access control.

require "csv"

class AdminsController < ApplicationController
  before_action :require_admin
  layout "dashboard"


def index
 @per_page = (params[:per_page] || 10).to_i.clamp(1, 100)
  @tab = params[:tab] || "contacts"
  @sort_direction = params[:sort] == "asc" ? "asc" : "desc"
  @next_direction = (@sort_direction == "asc" ? "desc" : "asc")
  query_str = "%#{params[:query]}%" if params[:query].present?

  if @tab == "users"
    @users = User.includes(:admin_role)
    @users = @users.where("users.username ILIKE ? OR users.email ILIKE ?", query_str, query_str) if query_str
    @users = @users.order(username: @sort_direction).page(params[:page]).per(@per_page)
  else
    @all_contacts = Contact.includes(:user).left_outer_joins(:user)
    if params[:owner_id].present?
      @all_contacts = @all_contacts.where(user_id: params[:owner_id])
    end
    if query_str
      @all_contacts = @all_contacts.where(
        "contacts.first_name ILIKE ? OR contacts.last_name ILIKE ? OR contacts.phone_number ILIKE ? OR users.username ILIKE ?",
        query_str, query_str, query_str, query_str
      ).distinct
    end
    @all_contacts = @all_contacts.order(first_name: @sort_direction).page(params[:page]).per(@per_page)
  end
  @owners = User.where(id: Contact.select(:user_id).distinct).order(:username)
end


def edit
  @user = User.find(params[:id])
  @user.build_admin_role unless @user.admin_role
end

def update
  @user = User.find(params[:id])
  if @user.update(user_params)
    redirect_to admins_path(tab: "users"), notice: "User #{@user.username} updated successfully."
  else
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  @user = User.find(params[:id])

  # 1. Prevent an admin from deleting themselves or other admins
  if @user.admin?
    redirect_to admins_path(tab: "users"), alert: "You cannot delete an admin user."
    return
  end

  # 2. Proceed with deletion for regular users
  if @user.destroy
    redirect_to admins_path(tab: "users"), notice: "User #{@user.username} deleted successfully."
  else
    redirect_to admins_path(tab: "users"), alert: "Failed to delete user #{@user.username}."
  end
end



def bulk_manage
  @contacts = Contact.where(id: params[:contact_ids])

  case params[:admin_bulk_action]
  when "delete"
    count = @contacts.count
    # destroy_all is better than delete_all as it handles callbacks/dependencies
    @contacts.destroy_all 
    
    # Use status: :see_other to force Turbo to refresh the page/list correctly
    redirect_to admins_path(tab: "contacts"), 
                notice: "Successfully deleted #{count} contacts.", 
                status: :see_other
    
  when "export_selected"
    send_data @contacts.to_csv, filename: "contacts_selected_#{Date.today}.csv"
      
  when "export_all"
    send_data Contact.to_csv, filename: "all_contacts_#{Date.today}.csv"
  else
    redirect_to admins_path(tab: "contacts"), 
                alert: "Invalid action.", 
                status: :see_other
  end
end


def show
  # We are looking for a Contact, but using the Admin Controller to show it in the sidebar
  @contact = Contact.find(params[:id])

  # This is the "Magic" that prevents the sidebar from showing the whole website inside itself
  render layout: false if turbo_frame_request?
end

  def new
    @user = User.new
    @user.build_admin_role
    respond_to do |format|
    format.html
    format.turbo_stream { render layout: "modal" }
  end
render layout: false
  end
  
def create
  @user = User.new(user_params)

  # Explicitly ensure a role is set if for some reason the admin didn't pick one
  @user.admin_role_code ||= "usr"

  if @user.save
    redirect_to admins_path, notice: "Account for #{@user.username} has been created."
  else
    # This will re-render the 'new' form and show validation errors
    render :new, status: :unprocessable_entity
  end
end



  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admins only."
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, admin_role_attributes: [ :role_code ])
  end

  def generate_csv(contacts)
    CSV.generate(headers: true) do |csv|
      csv << ["ID", "First Name", "Last Name", "Phone", "Owner"]
      contacts.each do |c|
        csv << [c.id, c.first_name, c.last_name, c.phone_number, c.user.username]
      end
    end
  end 

end
