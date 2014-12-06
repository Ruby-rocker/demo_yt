class NestedModels

  # Nested Attributes For email_ids
  module EmailIdCallBack

    def self.included(base)
      base.class_eval do
        before_validation :uniq_email_ids
      end
    end

    private #############################################

    def uniq_email_ids
      emails = email_ids.map(&:emails).uniq
      email_ids.each do |email_id|
        if email_id.emails.blank?
          if email_id.persisted?
            email_id.destroy
          else
            email_id.mark_for_destruction
          end
          next
        end
        # remove duplicate
        if emails.include?(email_id.emails) && !email_id.marked_for_destruction?
          emails.delete(email_id.emails)
        else
          if email_id.persisted?
            email_id.destroy
          else
            email_id.mark_for_destruction
          end
        end
      end
    end
  end

  # Nested Attributes For phone_numbers
  module PhoneNumberCallBack
    def self.included(base)
      base.class_eval do
        before_validation :uniq_phone_numbers if self.method_defined?(:phone_numbers)
        before_validation :uniq_notify_numbers if self.method_defined?(:notify_numbers)
      end
    end

    private #############################################

    def uniq_notify_numbers
      remove_duplicate_numbers(notify_numbers)
    end

    def uniq_phone_numbers
      remove_duplicate_numbers(phone_numbers)
    end

    def remove_duplicate_numbers(numbers)
      keys = numbers.map { |number| "#{number.name}#{number.area_code}#{number.phone1}#{number.phone2}" }.uniq
      numbers.each do |number|
        if number.area_code.blank? || number.phone1.blank? || number.phone2.blank?
          if number.persisted?
            number.destroy
          else
            number.mark_for_destruction
          end
          next
        end
        # remove duplicate
        key = "#{number.name}#{number.area_code}#{number.phone1}#{number.phone2}"
        if keys.include?(key) && !number.marked_for_destruction?
          keys.delete(key)
        else
          if number.persisted?
            number.destroy
          else
            number.mark_for_destruction
          end
        end
      end
    end
  end

  # twilio number release and soft delete
  module SoftDeletePhone

    def self.included(base)
      base.class_eval do
        default_scope where(is_deleted: false)
        validates :name, uniqueness: {scope: [:tenant_id, :is_deleted]}
      end
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_using_phone_line(phone_line)
        joins(:twilio_number).where(twilio_numbers: {phone_line: phone_line}).first
      end
    end

    def soft_delete
      if self.persisted?
        self.is_deleted = true
        self.transaction do
          if self.save
            # deactivate xps business
            if self.class.name.eql?('PhoneScript') #self.respond_to?(:campaign_id) # phone scripts
              CallCenter::XpsUsa.deactivate_business(self.campaign_id)
              release_twilio_number if self.twilio_number
            elsif self.respond_to?(:add_on_cancel) # voicemail & phone menu
              if self.add_on_cancel
                release_twilio_number if self.twilio_number
                true
              else
                raise ActiveRecord::Rollback
              end
            end
          end
        end
      end
    end

    private #############################################

    def release_twilio_number
      LongTasks.release_twilio_number(twilio_number.try(:phone_sid))
    end

  end

end