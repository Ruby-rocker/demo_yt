class AddPhoneScriptToNote < ActiveRecord::Migration
  def change
    add_column :notes, :phone_script_id, :integer, :after => :via_xps
  end
end
