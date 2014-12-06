class ChangeUserIdToPartnerMasterIdColumnName < ActiveRecord::Migration
  def change
    rename_column :partner_helps, :user_id, :partner_master_id
  end
end
