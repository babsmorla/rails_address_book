class ContactsController < ApplicationController
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login

  def index
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
        @contacts = query_scope.page(params[:page]).per(10)
        render layout: false if turbo_frame_request?
      end

      format.csv do
        @contacts = query_scope
        send_data @contacts.to_csv, filename: "contacts-#{Date.today}.csv"
      end
    end
end



def bulk_actions
  # Always scope to current_user for security!
  @contacts = current_user.contacts.where(id: params[:contact_ids])

  case params[:bulk_action]
  when "delete"
    count = @contacts.count
    @contacts.destroy_all
    redirect_to contacts_path, notice: "Successfully deleted #{count} contacts."
  when "export"
    send_data @contacts.to_csv, filename: "contacts_export_#{Date.today}.csv"
  else
    redirect_to contacts_path, alert: "Please select an action and contacts."
  end
end



  def show
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = current_user.contacts.build(contact_params)
    if @contact.save
      redirect_to contacts_path, notice: "Contact Created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to contacts_path, notice: "Contact updated successfully", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  if current_user != @contact.user
    redirect_to contacts_path, alert: "You cannot delete this contact"
  else
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to contacts_path, notice: "Contact deleted successfully" }

      format.turbo_stream
    end
  end
  end


  private
  

  def set_contact
      @contact = current_user.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to contacts_path, alert: "You are not authorized to view this contact."
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :phone_number)
  end

  def require_login
    unless current_user
      flash[:alert] = "You must be logged in to access this section"
      redirect_to new_session_path
    end
  end
end
