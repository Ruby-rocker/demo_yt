class PhoneMenuKey < ActiveRecord::Base
  acts_as_tenant(:tenant)
  
  belongs_to :tenant
  belongs_to :phone_menu
  belongs_to :routable, polymorphic: true
  has_one   :phone_number, as: :callable, dependent: :destroy

  PHONE_KEY = {1 => 'Press 1', 2 => 'Press 2', 3 => 'Press 3', 4 => 'Press 4', 5 => 'Press 5',
               6 => 'Press 6', 7 => 'Press 7', 8 => 'Press 8', 9 => 'Press 9'}

  attr_protected :tenant_id
  accepts_nested_attributes_for :phone_number, reject_if: :all_blank, allow_destroy: true

  validates :digit, uniqueness: {scope: [:phone_menu_id]}

  after_initialize { self.phone_number || self.build_phone_number }
  before_validation :delete_blank_number

  def route_to
    "#{routable_type}_#{routable_id}"
  end

  def route_to=(value)
    value = value.split('_')
    self.routable_type = value.first
    self.routable_id = value.last
  end

  private #############################################

  def delete_blank_number
    if phone_number.area_code.blank? || phone_number.phone1.blank? || phone_number.phone2.blank?
      if routable_id.blank? || routable_type.blank?
        self.errors[:department_number] << "can't be blank"
      else
        false
      end
    end
  end

end
