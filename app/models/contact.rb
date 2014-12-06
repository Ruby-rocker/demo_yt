class Contact < ActiveRecord::Base
  acts_as_tenant(:tenant)

  attr_protected :tenant_id

  belongs_to :tenant
  belongs_to :status_label
  belongs_to :user
  has_one    :address, as: :locatable, dependent: :destroy
  has_many   :phone_numbers, as: :callable, dependent: :destroy
  has_many   :email_ids, as: :mailable, dependent: :destroy
  has_many   :contact_tags, dependent: :destroy
  has_many   :tags, through: :contact_tags
  has_many   :notifications, as: :notifiable
  has_many   :appointments, dependent: :destroy
  has_many   :notes

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :email_ids, reject_if: :all_blank, allow_destroy: true

  include NestedModels::EmailIdCallBack
  include NestedModels::PhoneNumberCallBack

  COLORS = %w(#FF0000 #FFCC00 #0032CC #757779 #FFCCFF #996600 #FF32CC #6600CC #B6B6FF #76DCB3 #CCCC66
              #FF9900 #22B0D8 #009999 #00FFA6 #00FFFF #80BFFF #CC4E78)

  attr_reader :tag_tokens

  def tag_tokens=(ids)
    self.tag_ids = ids.split(",").uniq
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def full_name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def self.search_contact(search)
    if search
      search = search.downcase
      s = search.split
      where('LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ?', "%#{s.first}%", "%#{s.last}%")
    else
      Contact.where("1 = 1")
    end
  end

  def self.existing?(first_name, last_name, area_code, phone1, phone2)
    where("lower(first_name) = ? AND lower(last_name) = ?", first_name.downcase, last_name.downcase)
    .joins(:phone_numbers).where(phone_numbers: {area_code: area_code, phone1: phone1, phone2: phone2})
    .readonly(false).first
    #.joins(:email_ids).where(email_ids: {emails: email})
  end

  def self.is_existing_contact(contact)
    email_ids = contact[:email_ids_attributes].values.map{|e| e[:emails]} if contact[:email_ids_attributes].present?
    contact[:phone_numbers_attributes].values.each do |ph|
      @contact = Contact.where("first_name = ? and last_name = ?", contact[:first_name], contact[:last_name]).joins(:phone_numbers).where("phone_numbers.name = ? and phone_numbers.area_code = ? and phone_numbers.phone1 = ? and phone_numbers.phone2 = ?", ph[:name], ph[:area_code], ph[:phone1], ph[:phone2]).pluck(:id)
      break if @contact.present?
    end
    return @contact
  end

  def self.import_csv(file, curr_user)
    csv_text = File.read(file.path)
    CSV.parse(csv_text, headers: true) do |row|
      if row[0] == "#pn"
        phone_number = PhoneNumber.create(name: row[1], area_code: row[2], phone1: row[3], phone2: row[4], callable_id: @contact.id, callable_type: "Contact")
      elsif row[0] == "#addr"
        address = @contact.address.present? ? @contact.address : Address.new
        address.timezone = row[1]
        address.street = row[2]
        address.suite = row[3]
        address.city = row[4]
        address.state = row[5]
        address.country = row[6]
        address.zip_code = row[7]
        address.locatable_id = @contact.id
        address.locatable_type = "Contact"
        address.save!
      elsif row[0] == "#emails"
        email_id = EmailId.find_by_emails_and_mailable_id(row[1], @contact.id).present? ? EmailId.find_by_emails(row[1]) : EmailId.new
        email_id.emails = row[1]
        email_id.mailable_id = @contact.id
        email_id.mailable_type = "Contact"
        email_id.save!
      elsif row[0] == "#notes"
        note = Note.new
        note.via_xps = row[1]
        note.content = row[2]
        note.contact_id = @contact.id
        note.user_id = curr_user.id
        note.save!
      elsif row[0] == "#tags"
        @tag = Tag.find_by_name(row[1])
        @tag = Tag.create(name: row[1]) unless @tag.present?
        contact_tag = ContactTag.new
        contact_tag.contact_id = @contact.id
        contact_tag.tag_id = @tag.id
        contact_tag.user_id = curr_user.id
        contact_tag.save!
      elsif !row["first_name"].blank?
        @contact = Contact.find_by_first_name_and_last_name(row["first_name"], row["last_name"])
        @contact = Contact.create(first_name: row["first_name"], last_name: row["last_name"], via_xps: row["via_xps"], user_id: curr_user.id) unless @contact.present?
      end
    end
  end
end