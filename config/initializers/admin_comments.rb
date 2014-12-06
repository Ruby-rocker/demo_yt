module ActiveAdmin
  module Comments
    module Views
      class Comments < ActiveAdmin::Views::Panel
        def build_comment_form
          self << active_admin_form_for(ActiveAdmin::Comment.new, :url => comment_form_url, :html => {:class => "inline_form"}) do |form|
            form.inputs do
              form.input :resource_type, :input_html => { :value => ActiveAdmin::Comment.resource_type(@record) }, :as => :hidden
              form.input :resource_id, :input_html => { :value => @record.id }, :as => :hidden
                form.input :body, :input_html => { :size => "80x8" }, :label => false, :as => :ckeditor
            end
            form.actions do
              form.action :submit, :label => I18n.t('active_admin.comments.add'), :button_html => { :value => I18n.t('active_admin.comments.add') }
            end
          end
        end
      end
    end
  end

  class Comment  < ActiveRecord::Base
    after_create :send_email

    def send_email
      AdminMailer.delay.comment_created(self.id) if self.resource_type == "Help"
    end
  end
end