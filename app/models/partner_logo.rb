class PartnerLogo < ActiveRecord::Base
  attr_accessible :partner_master_id, :logo
  belongs_to :partner_master
  has_attached_file :logo,
                    url: "/system/:class/:id/:attachment/:style.:extension",
                    path: ":rails_root/public/system/:class/:id/:attachment/:style.:extension",
                    :styles => { :thumb => "50x160>" }


  validates_attachment_presence :logo
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  validate :check_dimensions, :unless => "errors.any?"

  def check_dimensions
    temp_file = logo.queued_for_write[:original]
    unless temp_file.nil?
      dimensions = Paperclip::Geometry.from_file(temp_file)
      width = dimensions.width
      height = dimensions.height
      unless width == 320 && height == 100
        errors.add(:logo,'must have width 320px and height 100px')
      end
    end
  end

end
