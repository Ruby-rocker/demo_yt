module ActiveRecordExtension

  extend ActiveSupport::Concern

  included do
    before_validation :squish_name, if: 'respond_to?(:name=)'
  end

  # add your static(class) methods here
  module ClassMethods

  end

  private #############################################

  def squish_name
    if self.name && self.name.respond_to?(:squish)
      self.name = self.name.squish
    end
  end

end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)
