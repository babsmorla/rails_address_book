class ContactsController < ApplicationController
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login

  layout :determine_layout


  def index
    @per_page = (params[:per_page] || 10).to_i.clamp(1, 100)
   query_scope = current_user.contacts.order(:first_name)

    # 2. Apply search filters if present
    if params[:query].present?
      search_query = "%#{params[:query]}%"
      query_scope = query_scope.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR phone_number ILIKE ?",
        search_query, search_query, search_query
      )
    end

    # 3. Handle different formats
    respond_to do |format|
      format.html do
        @contacts = query_scope.page(params[:page]).per(@per_page)
        render layout: false if turbo_frame_request?
      end

      format.csv do
        @contacts = query_scope
        send_data @contacts.to_csv, filename: "contacts-#{Date.today}.csv"
      end
    end
end


def bulk_actions
  # 1. Determine Scope: Admins see all, Users see theirs
  scope = current_user.admin? ? Contact : current_user.contacts
  @contacts = scope.where(id: params[:contact_ids])

  case params[:bulk_action]
  when "delete"
    count = @contacts.count
    @contacts.destroy_all

    return_path = current_user.admin? ? admins_path(tab: "contacts") : contacts_path
    redirect_to return_path, notice: "Successfully deleted #{count} contacts."

  when "export"
    
    send_data @contacts.to_csv, filename: "contacts_export_#{Date.today}.csv"

  else
    return_path = current_user.admin? ? admins_path(tab: "contacts") : contacts_path
    redirect_to return_path, alert: "Please select an action and contacts."
  end
end



  def show
  end

  def new
  @contact = Contact.new
  respond_to do |format|
    format.html
    format.turbo_stream { render layout: "modal" }
  end
render layout: false if params[:turbo_frame].present?
  end

  def create
    if current_user.admin? && params[:contact][:user_id].present?
      @contact = Contact.new(contact_params)
    else
      @contact = current_user.contacts.build(contact_params.except(:user_id))
    end

    if @contact.save
      if current_user.admin?
        redirect_to admins_path, notice: "Contact created successfully"
      else
      redirect_to contacts_path, notice: "Contact created successfully."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      if current_user.admin?
        redirect_to admins_path, notice: "Contact updated successfully"
      else
      redirect_to contacts_path, notice: "Contact updated successfully", status: :see_other
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

def destroy
  target_path = if current_user.admin?
                  admins_path
  else
                  contacts_path
  end

  # 2. Perform the deletion
  if @contact.destroy
    respond_to do |format|
      format.html { redirect_to target_path, notice: "Contact deleted.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "Contact deleted." }
    end
  else
    redirect_to target_path, alert: "Failed to delete contact."
  end
end


  private


  def set_contact
    if current_user.admin?
      @contact = Contact.find(params[:id])
    else
      @contact = current_user.contacts.find(params[:id])
    end

    
  rescue ActiveRecord::RecordNotFound
    redirect_to contacts_path, alert: "Contact not found or unauthorized."
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :phone_number, :user_id)
  end
  def require_login
    unless current_user
      flash[:alert] = "You must be logged in to access this section"
      redirect_to new_session_path
    end
  end

  def determine_layout
    if current_user&.admin?
      "dashboard"
    else
      "application"
    end
  end
end
