module Settings
  class ContactsController < ApplicationController

    add_breadcrumb "Settings", :settings_dashboard_index_path

    def index
      @status_label = StatusLabel.new
      #@status_label.name.build
      @tag = Tag.new
      @status_labels = StatusLabel.all
    	@tags = Tag.all
    end

    def create
      count = 0
      count1 = 0
      count2 = 0
      count3 = 0

      if params["color_code"].present?
        params["color_code"].keys.each_with_index do |key, index|
          params[:color_code][key] = params[:color_code][key].uniq
          params[:color_code][key].delete_if(&:empty?) if (params[:color_code][key].length > 1)
        end
          params[:color_code] = params[:color_code].values.flatten
      end
      
      if params["color_code_new"].present?
        params["color_code_new"].keys.each_with_index do |key, index|
          params[:color_code_new][key] = params[:color_code_new][key].uniq
          params[:color_code_new][key].delete_if(&:empty?) if (params[:color_code_new][key].length > 1)
        end
        params[:color_code_new] = params[:color_code_new].values.flatten
      end
      

      
      params[:status].each do |key , name|
        if key == 'st_name'
          name.each do |nm|
            @status_labels = StatusLabel.create!(name: nm, color: params[:color_code_new][count2])
            count2 = count2 + 1
          end
        else
            @status_labels = StatusLabel.find(key)
            @status_labels.update_attributes(:name => name , :color => params[:color_code][count])
            count = count + 1
        end
      end
      
      if params["color"].present?
        params["color"].keys.each_with_index do |key, index|
          params[:color][key] = params[:color][key].uniq
          params[:color][key].delete_if(&:empty?) if (params[:color][key].length > 1)
        end
        params[:color] = params[:color].values.flatten

      end
      if params["color_tag_new"].present?
        params["color_tag_new"].keys.each_with_index do |key, index|
          params[:color_tag_new][key] = params[:color_tag_new][key].uniq
          params[:color_tag_new][key].delete_if(&:empty?) if (params[:color_tag_new][key].length > 1)
        end
        params[:color_tag_new] = params[:color_tag_new].values.flatten
      end
      
      
      params[:tag].each do |key , tag_name|
        if key == 'name'
          tag_name.each do |nm|
            @tags = Tag.create!(name: nm, color: params[:color_tag_new][count3])
            count3 = count3 + 1
          end
        else
          @tags = Tag.find(key)
          @tags.update_attributes(:name => tag_name , :color => params[:color][count1])
          count1 = count1 + 1
        end
      end
      

      if params[:contact_csv]
        Contact.import_csv(params[:contact_csv], current_user)
        ClientMailer.delay.contacts_imported(current_tenant)
        Notification.create(title: 'Contacts were imported to the system', notifiable_type: 'Contact', notify_on: Time.now,
          content: "<span>Contacts were imported in to your system by #{current_user.full_name}.</span>")
      end
        redirect_to settings_contacts_path 
    end
    def destroy
      @tag = Tag.find(params[:id])
      @tag.destroy
      redirect_to settings_contacts_path 
    end
    def delete_status
      @status = StatusLabel.find(params[:id])    
      if @status.delete_label!
        render :js => "alert('Status Label Deleted Successfully');"
      else
        render :js => "alert('Status Label Not Deleted');"
      end
    end

    def add_status_label
      @index = params[:index]
    end

    def export_contacts
      @contacts = Contact.all
      respond_to do |format|
        csv = CSV.generate do |csv|
          column_names = ["first_name","last_name","via_xps"]
          column_phone_numbers = ["","name","area_code","phone1","phone2"]
          column_address = ["","timezone","street","suite","city","state","country","zip_code"]
          column_email_ids = ["","email"]
          column_notes = ["","via_xps","content"]
          column_tags = ["","name"]
          csv << column_names
          @contacts.each do |contact|
            contact_array = []
            column_names.each do |column|
                contact_array << contact.send(column)
            end
            csv << contact_array
          
            if !contact.phone_numbers.empty?
              csv << ["", "Phone numbers"]
              csv << column_phone_numbers
              contact.phone_numbers.each do |phone_number|
                csv << ["#pn", phone_number.name, phone_number.area_code, phone_number.phone1, phone_number.phone2]
              end
            end
            if contact.address.present?
              csv << ["", "Address"]
              csv << column_address
              csv << ["#addr", contact.address.timezone, contact.address.street, contact.address.suite, contact.address.city, contact.address.state, contact.address.country, contact.address.zip_code]
            end
            if !contact.email_ids.empty?
              csv << ["", "Emails"]
              csv << column_email_ids
              contact.email_ids.each do |email|
                csv << ["#emails", email.emails]
              end
            end
            if !contact.notes.empty?
              csv << ["", "Notes"]
              csv << column_notes
              contact.notes.each do |note|
                csv << ["#notes", note.via_xps, note.content]
              end
            end
            if !contact.tags.empty?
              csv << ["", "Tags"]
              csv << column_tags
              contact.tags.each do |tag|
                csv << ["#tags", tag.name]
              end
            end
          end
        end
        format.csv { send_data csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=exportdata.csv" }
      end
      ClientMailer.delay.contacts_exported(current_tenant)
      Notification.create(title: 'Contacts were exported from the system', notifiable_type: 'Contact', notify_on: Time.now,
        content: "<span>Contacts were exported from to your system by #{current_user.full_name}.</span>")
    end

    def add_tag
      @index = params[:index]
    end
  end
end
