class AddCreditMenuMinutesToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :credit_menu_minutes, :integer, default: 0, null: false, :after => :credit_minutes
    add_column :tenants, :credit_mail_minutes, :integer, default: 0, null: false, :after => :credit_minutes

    add_column :tenant_configs, :credit_for, :string, default: 'PhoneScript', null: false

  end
end
