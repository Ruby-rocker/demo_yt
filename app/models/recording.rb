class Recording < ActiveRecord::Base
  acts_as_tenant(:tenant)

  extend CustomFilter
  
  belongs_to :call_detail, :foreign_key => "call_sid", :primary_key => "call_sid"
  has_many :notifications, as: :notifiable
  belongs_to :tenant

  cattr_accessor :displaying_range

  scope :super_user_notifications, order('created_at DESC')

  def self.unheard
    where(is_heard: false).count
  end

  def self.phone_script_records
    joins(call_detail: :twilio_number).where(twilio_numbers: {twilioable_type: 'PhoneScript'}).order("recordings.created_at DESC")
  end
  
  def self.voicemail_records
    joins(call_detail: :twilio_number).where(twilio_numbers: {twilioable_type: 'Voicemail'}).order("recordings.created_at DESC")
  end

  def self.caller(record_id)
    @phone_line = select("twilio_numbers.phone_line").joins(call_detail: :twilio_number).where(recordings: {id: record_id})
    return @phone_line[0].phone_line
  end
  def self.voicemail_name(record_id)
  
    @voicemail_name = select("voicemails.name").joins(
      "INNER JOIN `call_details` ON `call_details`.`call_sid` = `recordings`.`call_sid` 
      INNER JOIN `twilio_numbers` ON `twilio_numbers`.`phone_sid` = `call_details`.`phone_number_sid` 
      INNER JOIN voicemails ON voicemails.id = twilio_numbers.twilioable_id"
      ).where(
      "twilio_numbers.twilioable_type = 'Voicemail' AND 
      recordings.id = #{record_id}")
    return @voicemail_name[0].name
  end

  def self.phone_script_name(record_id)
    @phone_script_name = select("phone_scripts.name").joins(
      "INNER JOIN `call_details` ON `call_details`.`call_sid` = `recordings`.`call_sid` 
      INNER JOIN `twilio_numbers` ON `twilio_numbers`.`phone_sid` = `call_details`.`phone_number_sid` 
      INNER JOIN phone_scripts ON phone_scripts.id = twilio_numbers.twilioable_id"
      ).where(
      "twilio_numbers.twilioable_type = 'PhoneScript' AND 
      recordings.id = #{record_id}")
    return @phone_script_name[0].name
  end

  def self.all_phone_script_names
    @all_phone_script_names = select("DISTINCT phone_scripts.name").joins(
      "INNER JOIN `call_details` ON `call_details`.`call_sid` = `recordings`.`call_sid` 
      INNER JOIN `twilio_numbers` ON `twilio_numbers`.`phone_sid` = `call_details`.`phone_number_sid` 
      INNER JOIN phone_scripts ON phone_scripts.id = twilio_numbers.twilioable_id"
      ).where(
      "twilio_numbers.twilioable_type = 'PhoneScript'")
    return @all_phone_script_names
  end

  after_create :create_notifications

  def store_recording
    Dir.mkdir('storage') unless Dir.exists?('storage')
    Dir.mkdir('storage/call_recordings') unless Dir.exists?('storage/call_recordings')

    unless File.exists?("storage/call_recordings/#{recording_sid}.mp3")
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.path)
      resp = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req)}
      f = File.new("storage/call_recordings/#{recording_sid}.mp3",'wb')
      f.write(resp.body)
      f.close
    end
  end

  private ##################################

  def create_notifications
    store_recording # Store recording locally
    #notifications.create(title: 'Our agents have added new recordings to your account.', notify_on: Time.now,
    #  content: "<span>A total of #{Recording.unheard} call recordings have been added to the account for review.</span>")

    if self.call_detail.callable_type.eql?("PhoneScript")
      script_name = self.call_detail.callable.name
      call_from = self.call_detail.call_from
      notifications.create(title: 'A new recording was added to your account', notify_on: Time.now,
        content: "<span>A call recording was added to your account for the script #{script_name} from phone number #{call_from}.</span>")
    end
  end


end
