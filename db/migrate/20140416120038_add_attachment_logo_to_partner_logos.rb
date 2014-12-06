class AddAttachmentLogoToPartnerLogos < ActiveRecord::Migration
  def self.up
    change_table :partner_logos do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :partner_logos, :logo
  end
end
