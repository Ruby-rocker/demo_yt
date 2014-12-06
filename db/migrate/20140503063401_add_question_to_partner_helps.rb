class AddQuestionToPartnerHelps < ActiveRecord::Migration
  def change
    add_column :partner_helps, :question, :string
  end
end
