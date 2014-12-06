ActiveAdmin.register AdminUser do
  menu :priority => 2
  #actions :all, :except => [:destroy, :new, :edit]
  index do                            
    column :email                     
    column :current_sign_in_at        
    column :last_sign_in_at           
    column :sign_in_count             
    default_actions                   
  end                                 

  filter :email                       

  form do |f|                         
    f.inputs "Admin Details" do       
      f.input :email                  
      f.input :password
      f.input :password_confirmation
    end                               
    f.actions                         
  end

  after_create do |user|
    user.reset_password_token = SecureRandom.urlsafe_base64
    user.reset_password_sent_at = Time.now
    user.save
    AdminMailer.delay.admin_user_added(user.id, current_admin_user.email)
  end

  controller do
    skip_before_filter :decide_redirection
  end
end                                   
