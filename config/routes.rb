Yestrak::Application.routes.draw do

  constraints :subdomain => PARTNER_SUBDOMAIN do
    devise_for :partner_masters, :controllers => {:confirmations => 'confirmations'}
    devise_scope :partner_master do
      put "/confirm" => "confirmations#confirm"
    end

    namespace :partners do
      resources :dashboard do
        collection do
          match 'upload_logo' => "dashboard#upload_logo"
        end
      end
      resources :stats do
        collection do
          match "daterange_selector" => "stats#daterange_selector", as: "daterange_selector"
        end
      end

      resources :statements do #, only: [:index]
        collection do
          match "daterange_selector" => "statements#daterange_selector", as: "daterange_selector"
          post "paid_commission/:commission_id" => "statements#paid_commission", as: "paid_commission"
          post "paid_bonus" => "statements#paid_bonus", as: "paid_bonus"
  
        end
      end
      resources :account do
        match 'update' => "account#update"
        get :verify_paypal_account
      end
      resources :custom_links, only: [:index] do
        collection do
          match "edit_partner_page" => "custom_links#edit_partner_page", as: "edit_partner_page"
        end
      end
      resources :partner_docusign do
        collection do
          match 'upload_agreement' => 'partner_docusign#upload_agreement'
          match 'embedded_signing' => "partner_docusign#embedded_signing"
          match 'docusign_response' => "partner_docusign#docusign_response"
        end
      end
      resources :partner_helps
      match 'help_confirmation' => 'partner_helps#help_confirmation'
    end

    # Partner User change password after login
    get "partner_users/edit_user_password" => "partner_users#edit_user_password"
    post "partner_users/update_user_password" => "partner_users#update_user_password"
    get "partner_users/login/:auth_token" => "partner_users#login", as: 'login_from_admin_site'

    match "partner_users/check_current_password" => "partner_users#check_current_password"

    root :to => "partners/dashboard#index"
  end

  constraints :subdomain => ADMIN_SUBDOMAIN do
    ActiveAdmin.routes(self)
    devise_for :admin_users, ActiveAdmin::Devise.config.merge(:path => '')
    resources :recordings do
      member do
        get 'admin_download'
      end
    end
  end

  get "tags/index"
  # devise_for :users, controllers: {sessions: "sessions"}
  # API controllers for wordpress marketing site 
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1 do
      scope '/blog_details' do
        post 'fetch_blog_details' => 'blog_details#fetch_blog_details'
        post 'delete_blog_detail' => 'blog_details#delete_blog_detail'
      end
      scope '/contacts' do
        match 'create' => 'contacts#create'
      end
      scope 'subscription' do
        match 'create' => 'subscription#create'
        match 'validate_email' => 'subscription#validate_email'
        match 'discount_amount' => 'subscription#discount_amount'
      end
      scope 'partner' do
         match 'partner_detail' => 'partner#partner_detail'
         match 'partner_logo' => 'partner#partner_logo'
         match 'partner_landing_page_click' => 'partner#partner_landing_page_click'
      end
    end
  end

  scope '/webhooks' do
    post '/process' => 'webhooks#handle' #, :as => :process_webhook, :via => :post
    get '/process' => 'webhooks#verify' #, :as => :verify_webhook, :via => :get
  end

  # Settings allowed to owner or admin
  namespace :settings do
    resources :dashboard, only: [:index]
    resources :businesses, except: [:show] do
      collection do
        match "check_business_name" => "businesses#check_business_name"
      end
    end
    resources :phone_scripts, except: [:show] do
      member do
        get 'pick_number'
        put 'choose_number'
        post 'search_local_number'
        post 'search_tollfree_number'
        get 'set_script'
        put 'update_script'
        put 'complete'
        get 'routing_notification'
      end
      get 'check_for_uniq_name', on: :collection
    end
    resources :voicemails, except: [:show] do
      member do
        get 'pick_number'
        put 'choose_number'
        post 'search_local_number'
        post 'search_tollfree_number'
      end
      get 'check_for_uniq_name', on: :collection
    end
    resources :phone_menus, except: [:show] do
      member do
        get 'pick_number'
        put 'choose_number'
        post 'search_local_number'
        post 'search_tollfree_number'
      end
      get 'check_for_uniq_name', on: :collection
    end
    resources :call_recordings, only: [:index] do
      put 'update_recordings', on: :collection
    end
    resources :calendars, except: [:show] do
      collection do
        match "add_appointment_details" => "calendars#add_appointment_detail"
        match "check_duplicate_name" => "calendars#check_duplicate_name"
        match :remove_calendar_hour
        match "ical" => "calendars#ical", as: :ical
      end
    end
    resources :contacts, except: [:show] do
      # get :autocomplete_note_name, :on => :collection
      collection do
        # match "save_contact_settings" => "contacts#create_contact_settings", as: "save"
        match "add_status_label" => "contacts#add_status_label"
        match "add_tag" => "contacts#add_tag"
        get "delete_status/:id" => "contacts#delete_status"
        get :export_contacts
      end
    end
    resources :users, except: [:show] do
      collection do
        match "check_duplicate_email" => "users#check_duplicate_email"
        match "my_account" => "users#my_account"
        get :user_cancellation
        post :cancellation
        post :submit_suggestion
      end
    end
    resources :billings, except: [:show] do
      collection do
        match "upgrade_downgrade" => "billings#upgrade_downgrade"
        match "view_all_payments" => "billings#view_all_payments"
        match "view_invoice/:id" => "billings#view_invoice", as: :view_invoice
        match "download_invoice" => "billings#download_invoice"
      end
    end
  end
  
  resources :voicemail do
    collection do
      match "daterange_selector" => "voicemail#daterange_selector", as: "daterange_selector"
    end
  end
  # Calendar view
  resources :calendars, except: [:show] do
    collection do
      post :appoint_view
      get :appointment_view_month
      get :appointment_view_week
      get :appointment_day
      get :block_timing_modification
      post :list_calendars_appointments
    end
  end
  scope :calendars do
    get '(/:year(/:month))', to: 'calendars#index', :as => :calendars, :constraints => {:year => /\d{4}/, :month => /\d{1,2}/}
    match 'weekly(/:date)' => 'calendars#weekly', :as => :weekly
    get 'daily(/:date)' => 'calendars#daily', :as => :daily
  end

  # Google Sync
  match "/auth/:provider/callback" => "calendars#google_sync"
  match "cancel_google_sync" => 'calendars#cancel_google_sync', as: :cancel_google_sync

  # Appointments
  resources :appointments do
    match 'get_contact_detail/:contact_id' => 'appointments#get_contact_detail', as: :get_contact_detail
    collection do
      match "is_valid_time" => "appointments#is_valid_time"
    end
  end

  # Dashboard notification
  resources :notifications, only: [:index] do
    collection do
      match "daterange_selector" => "notifications#daterange_selector", as: "daterange_selector"
      match "create_user_notification_entry" => "notifications#create_user_notification_entry"
    end
  end

  resources :registrations, only: [:index] do
    collection do
      # get "rejoin/:auth_token" => "registrations#rejoin", as: "rejoin"
      get :rejoin
      post :process_rejoin
      post :check_coupen
    end
  end


  resources :call_recordings do
    collection do
      match "daterange_selector" => "call_recordings#daterange_selector", as: "daterange_selector"
    end
  end

  match 'voicemail/:sid' => 'call_recordings#voicemail', as: 'voicemail_recording'
  match 'voicemail_test/:sid' => 'call_recordings#voicemail_test'

  # Contacts display
  resources :contacts, except: [:show] do
    collection do
      get "autocomplete_contact_first_name" => "contacts#autocomplete_contact_first_name"
      get "autocomplete_tag_name" => "contacts#autocomplete_tag_name"
      get "add_phone_to_contact" => "contacts#add_phone_to_contact"
      get "add_email_to_contact" => "contacts#add_email_to_contact"
      get "destroy_phone/:phone_id" => "contacts#destroy_phone"
      get "destroy_email/:email_id" => "contacts#destroy_email"
      post "find_statuslabels" => "contacts#find_statuslabels"
      match 'view_all_notes/:id' => 'contacts#view_all_notes', as: "view_all_notes"
      match 'destroy_note/:note_id' => 'contacts#destroy_note', as: "destroy_note"
    end
  end
  
  # MANAGE PHONE CALLS
  scope '/manage_calls', defaults: {format: 'xml'} do
    match 'phone_script' => 'manage_phone_calls#phone_script', as: 'manage_phone_script'
    match 'phone_menu' => 'manage_phone_calls#phone_menu', as: 'manage_phone_menu'
    match 'voicemail' => 'manage_phone_calls#voicemail', as: 'manage_voicemail'
    match 'gather_digits' => 'manage_phone_calls#gather_digits'
    match 'record_call' => 'manage_phone_calls#record_call'
    match 'call_complete' => 'manage_phone_calls#call_complete', as: 'manage_call_complete'
    match 'download(/:id)' => 'call_recordings#download', as: :download_recording
  end

  # calendar paths
  scope '/calendar' do
    get '(/:year(/:month))', to: 'calendars#index', :as => :calendars, :constraints => {:year => /\d{4}/, :month => /\d{1,2}/}
    match 'weekly(/:date)' => 'calendars#weekly', :as => :weekly
    get 'daily(/:date)' => 'calendars#daily', :as => :daily
  end
  resources :appointments, except: [:index, :show]

  # User change password after login
  get "users/edit_user_password" => "users#edit_user_password"
  get "users/login/:auth_token" => "users#login", as: 'login_from_admin'
  post "users/update_user_password" => "users#update_user_password"
  match "users/check_current_password" => "users#check_current_password"

  # Account confirmation / Create account
  devise_for :users, :controllers => {:confirmations => 'confirmations'}
  devise_scope :user do
    put "/confirm" => "confirmations#confirm"
  end

  scope '/call_center' do
    match '/:auth' => 'call_center#index', as: :call_center
    match '/:auth/appointment_day'=> 'call_center#appointment_day', as: :appointment_day
  end

  resources :help
  match 'help_confirmation' => 'help#help_confirmation'

  mount Ckeditor::Engine => '/ckeditor'
  root :to => 'notifications#index'
end