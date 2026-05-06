class ContactsController < ApplicationController
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login

  layout :determine_layout

  # GET /contacts or /admins
  def index
    @per_page = (params[:per_page] || 10).to_i.clamp(1, 100)
    
    # Define scope: users see their own, admins see their own (or all via AdminController)
    query_scope = current_user.contacts.order(first_name: :asc)

    if params[:query].present?
      search_query = "%#{params[:query]}%"
      query_scope = query_scope.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR phone_number ILIKE ?",
        search_query, search_query, search_query
      )
    end

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

  # GET /contacts/new
  def new
    @contact = Contact.new
    respond_to do |format|
      # If requested via Turbo Frame, don't render the site-wide layout
      format.html { render layout: false if turbo_frame_request? }
      # If requested via Turbo Stream, use the modal layout shell
      format.turbo_stream { render layout: "modal" }
    end
  end

  # POST /contacts
  def create
    if current_user.admin? && params[:contact][:user_id].present?
      @contact = Contact.new(contact_params)
    else
      @contact = current_user.contacts.build(contact_params.except(:user_id))
    end

    if @contact.save
      target_path = current_user.admin? ? admins_path : contacts_path
      
      respond_to do |format|
        format.html { redirect_to target_path, notice: "Contact created successfully", status: :see_other }
        # status: :see_other (303) is required for Turbo to redirect properly after a POST
        format.turbo_stream { redirect_to target_path, notice: "Contact created successfully", status: :see_other }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # GET /contacts/1/edit
  def edit
    respond_to do |format|
      format.html { render layout: false if turbo_frame_request? }
    end
  end

  # PATCH/PUT /contacts/1
  def update
    if @contact.update(contact_params)
      target_path = current_user.admin? ? admins_path : contacts_path
      
      respond_to do |format|
        format.html { redirect_to target_path, notice: "Updated successfully", status: :see_other }
        format.turbo_stream { redirect_to target_path, notice: "Updated successfully", status: :see_other }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end


  def show
  end


  def destroy
  target_path = current_user.admin? ? admins_path : contacts_path

  if @contact.destroy
    respond_to do |format|
      # 1. Standard HTML: Uses standard flash for the next request (redirect)
      format.html { redirect_to target_path, notice: "Contact deleted.", status: :see_other }
      
      # 2. Turbo Stream: Uses flash.now for the current request (render)
      format.turbo_stream { flash.now[:notice] = "Contact deleted." }
    end
  else
    # Handle failure gracefully
    respond_to do |format|
      format.html { redirect_to target_path, alert: "Failed to delete contact.", status: :see_other }
      format.turbo_stream { flash.now[:alert] = "Failed to delete contact." }
    end
  end
end

  def bulk_actions
  scope = current_user.admin? ? Contact : current_user.contacts
  @contacts = scope.where(id: params[:contact_ids])
  return_path = current_user.admin? ? admins_path(tab: "contacts") : contacts_path

  case params[:bulk_action]
  when "delete"
    count = @contacts.count
    @contacts.destroy_all
    message = "Successfully deleted #{count} contacts."
    
    respond_to do |format|
      format.html { redirect_to return_path, notice: message, status: :see_other }
      # Turbo Stream allows us to redirect AND ensure the flash is handled
      format.turbo_stream { redirect_to return_path, notice: message, status: :see_other }
    end

  when "export"
    send_data @contacts.to_csv, filename: "contacts_export_#{Date.today}.csv"

  else
    message = "Please select an action and contacts."
    respond_to do |format|
      format.html { redirect_to return_path, alert: message, status: :see_other }
      format.turbo_stream { redirect_to return_path, alert: message, status: :see_other }
    end
  end
end

  private

  def set_contact
    scope = current_user.admin? ? Contact : current_user.contacts
    @contact = scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to (current_user.admin? ? admins_path : contacts_path), 
                alert: "Contact not found.", 
                status: :see_other
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