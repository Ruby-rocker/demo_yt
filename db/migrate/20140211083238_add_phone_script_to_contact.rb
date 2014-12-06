class AddPhoneScriptToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :phone_script_id, :integer, :after => :status_label_id
  end
end
