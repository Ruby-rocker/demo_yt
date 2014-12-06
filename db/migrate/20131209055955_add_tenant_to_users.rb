class AddTenantToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :tenant_id, :integer, :after => :id
  	add_column :users, :plan_bid, :string, :after => :subdomain
  	
  	add_index :users, :tenant_id 
  end
end
