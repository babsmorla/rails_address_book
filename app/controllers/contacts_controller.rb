class ContactsController < ApplicationController

  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  def index
  @contacts = current_user.contacts

  if params[:query].present?
    @contacts = @contacts.where(
      "first_name ILIKE ? OR last_name ILIKE ?", 
      "%#{params[:query]}%", 
      "%#{params[:query]}%"
    )
  end

  # This line prevents the "Double Table" look by only sending the frame content
  render layout: false if turbo_frame_request?
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
      render :new
    end

  end

  def edit
    # if @contact.user != current_user
    #   redirect_to contact_path(@contact), alert: "You cannot edit this contact"
    # end
  end

  def update
    if @contact.update(contact_params)
      redirect_to contacts_path, notice: "Contact updated successfully", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end 
  end

  def destroy
    if current_user  !=  @contact.user
      redirect_to contacts_path, alert: "You cannot delete this contact"
      
    else 
      @contact.destroy
      redirect_to contacts_path, notice: "Contact deleted succefully"
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
