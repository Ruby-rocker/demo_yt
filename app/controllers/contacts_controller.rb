class ContactsController < ApplicationController
	load_and_authorize_resource
  autocomplete :tag, :name, :full => true, :display_value => :name
  autocomplete :contact, :first_name, :full => true

  def get_autocomplete_items(parameters)
   term = parameters[:term].downcase
   Contact.where('(LOWER(first_name) LIKE ?)', "%#{term}%")
  end

  def autocomplete_tag_name(parameters)
    term = parameters[:term].downcase
    Contact.where('(LOWER(name) LIKE ?)', "%#{term}%")
  end

	def index
    @status_label_id = params[:status_label_id] || []
    @tag_id = params[:tag_id] || []
    session[:limit] = params[:limit] || session[:limit]
    @status_labels = StatusLabel.all
    @tags = Tag.all
    
    if @status_label_id.present? || @tag_id.present?
      contact_tags = ContactTag.find(:all, :conditions => ["(tag_id IN (?))", @tag_id])
      session[:con_id] = Array.new
      contact_tags.each do |ct|
        session[:con_id] << ct.contact_id
      end
      @contacts = Contact.find(:all, :conditions => ["(status_label_id IN (?)) || (id IN (?)) ", @status_label_id, session[:con_id]])
      @total_record = @contacts.size
      @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10)
      @record = {name:'contacts',path:contacts_path,remote:true}
     
    else
      @contacts = Contact.search_contact(params[:search])
      @total_record = @contacts.size
      @contacts = @contacts.page(params[:page]).per(session[:limit])
      @record = {name:'contacts',path:contacts_path,remote:true}
    end
  end
  def find_statuslabels
     
    if params[:statuslabels].present?
        id_list = params[:statuslabels].keys
        flags = params[:statuslabels].values.map{|v| v.values}.flatten
        id_array = []
        id_list.each_with_index do |id, index|
          (id_array << id) if flags[index] != "0"
        end
      end
      if params[:tags].present?
        id_list1 = params[:tags].keys
        flags1 = params[:tags].values.map{|v| v.values}.flatten
        id_array1 = []
        id_list1.each_with_index do |id, index|
          (id_array1 << id) if flags1[index] != "0"
        end
      end
        redirect_to contacts_path("status_label_id" => id_array, "tag_id" => id_array1)
  end

  def new
    @contact = Contact.new
    @contact.build_address
    @contact.phone_numbers.build
    @contact.email_ids.build
    @status_labels = StatusLabel.all
    render partial: 'new'
  end

  def create
    if params[:us_state].present?
      @contact.address.state = params[:us_state]
    elsif params[:ca_state].present?
      @contact.address.state = params[:ca_state]
    elsif params[:other_state].present?
      @contact.address.state = params[:other_state]
    end
  
    
    if @contact.save!
      if params[:content].present?
        note = Note.new(:content => params[:content], :contact_id => @contact.id, :user_id => current_user.id )
        note.save!
      end
      @contact.notifications.create(title: 'Congrats! A new contact was entered', notify_on: Time.now,
                           content: "<span>The contact #{@contact.full_name} was added to the system by #{current_user.full_name}.</span>" \
                                   "<span>#{@contact.phone_numbers.first.try(:print_number)}</span>")
      redirect_to contacts_path, notice: "Contact saved successfully"
    else
      render :new
    end
  end

  def edit
    @contact = Contact.find(params[:id])
    @phone_numbers = @contact.phone_numbers
    @email_ids = @contact.email_ids.present? ? @contact.email_ids : @contact.email_ids.build
    @status_labels = StatusLabel.all
    @all_notes = @contact.notes
    @notes = (@contact.notes).order("created_at DESC").limit(2)
    @tags = @contact.tags.map(&:attributes).to_json
    render partial: 'edit'
  end

  def update
    @contact = Contact.find(params[:contact][:id])

    if params[:us_state].present?
      params[:contact][:address_attributes][:state] = params[:us_state]
    elsif params[:ca_state].present?
      params[:contact][:address_attributes][:state] = params[:ca_state]
    elsif params[:other_state].present?
      params[:contact][:address_attributes][:state] = params[:other_state]
    end

    if @contact.update_attributes!(params[:contact])
      if params[:content].present?
        note = Note.new(:content => params[:content], :contact_id => @contact.id, :user_id => current_user.id )
        note.save!
      end
      @contact.notifications.create(title: 'A contact was edited', notify_on: Time.now,
        content: "<span>The contact #{@contact.full_name} was edited in the system by #{current_user.full_name}.</span>")
      redirect_to contacts_path, notice: "Contact saved successfully"
    else
      render :edit
    end
  end

  def destroy
    #abort
    @contact = Contact.find(params[:id])
    @contact_notification = Contact.find(params[:id])
    @contact.destroy
    @contact_notification.notifications.create(title: 'A contact was deleted', notify_on: Time.now,
      content: "<span>The contact #{@contact.full_name} was deleted from the system by #{current_user.full_name}.</span>")
  end

  def add_phone_to_contact
    @count = params[:count]
  end

  def add_email_to_contact
    @count = params[:count]
  end

  def view_all_notes
    contact = Contact.find(params[:id])
    @notes = (contact.notes).order("created_at DESC")
    render partial: 'view_all_notes', locals: {notes: @notes}
  end

  def destroy_note
    @note = Note.find(params[:note_id])
    @note.destroy
  end

  def destroy_phone
    @phone = PhoneNumber.find(params[:phone_id])
    @phone.destroy
    head :ok
  end

  def destroy_email
    @email = EmailId.find(params[:email_id])
    @email.destroy
    head :ok
  end
end
