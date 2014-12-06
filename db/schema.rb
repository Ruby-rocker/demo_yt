# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140626091229) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "add_on_logs", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "chargeable_id"
    t.string   "chargeable_type"
    t.decimal  "amount",          :precision => 8, :scale => 2
    t.decimal  "balance",         :precision => 8, :scale => 2, :default => 0.0
    t.datetime "deleted_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "prorated",                                      :default => false, :null => false
    t.date     "show_on"
    t.integer  "billing_cycle"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "add_on_logs", ["chargeable_id", "chargeable_type"], :name => "index_add_on_logs_on_chargeable_id_and_chargeable_type"
  add_index "add_on_logs", ["tenant_id"], :name => "index_add_on_logs_on_tenant_id"

  create_table "add_ons", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "subscription_id"
    t.string   "subscription_bid"
    t.string   "customer_bid"
    t.string   "type_of"
    t.integer  "type_id"
    t.string   "status"
    t.date     "next_due"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "add_ons", ["subscription_id"], :name => "index_add_ons_on_subscription_id"
  add_index "add_ons", ["tenant_id"], :name => "index_add_ons_on_tenant_id"

  create_table "addresses", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "locatable_id"
    t.string   "locatable_type"
    t.string   "timezone"
    t.string   "street"
    t.string   "suite"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip_code"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "addresses", ["locatable_id", "locatable_type"], :name => "index_addresses_on_locatable_id_and_locatable_type"
  add_index "addresses", ["tenant_id"], :name => "index_addresses_on_tenant_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "announcements", :force => true do |t|
    t.text     "message"
    t.boolean  "via_email"
    t.boolean  "via_sms"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "appointments", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "calendar_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "repeat",          :default => false, :null => false
    t.text     "schedule"
    t.string   "timezone"
    t.integer  "contact_id"
    t.integer  "phone_script_id"
    t.boolean  "via_xps",         :default => false, :null => false
    t.integer  "user_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "event_id"
  end

  add_index "appointments", ["calendar_id"], :name => "index_appointments_on_calendar_id"
  add_index "appointments", ["contact_id"], :name => "index_appointments_on_contact_id"
  add_index "appointments", ["phone_script_id"], :name => "index_appointments_on_phone_script_id"
  add_index "appointments", ["tenant_id"], :name => "index_appointments_on_tenant_id"
  add_index "appointments", ["user_id"], :name => "index_appointments_on_user_id"

  create_table "audio_files", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "audible_id"
    t.string   "audible_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "record_file_name"
    t.string   "record_content_type"
    t.integer  "record_file_size"
    t.datetime "record_updated_at"
  end

  add_index "audio_files", ["audible_id", "audible_type"], :name => "index_audio_files_on_audible_id_and_audible_type"
  add_index "audio_files", ["tenant_id"], :name => "index_audio_files_on_tenant_id"

  create_table "billing_infos", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_id"
    t.string   "email"
    t.string   "last_4",           :limit => 5
    t.string   "card_type"
    t.string   "bin",              :limit => 10
    t.string   "cardholder_name"
    t.string   "expiration_month"
    t.string   "expiration_year"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "billing_infos", ["tenant_id"], :name => "index_billing_infos_on_tenant_id"
  add_index "billing_infos", ["user_id"], :name => "index_billing_infos_on_user_id"

  create_table "billing_transactions", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "subscription_id"
    t.integer  "billable_id"
    t.string   "billable_type"
    t.string   "customer_id"
    t.string   "transaction_bid"
    t.string   "subscription_bid"
    t.integer  "billing_cycle"
    t.decimal  "balance",                   :precision => 8, :scale => 2, :default => 0.0
    t.string   "status"
    t.string   "type_of"
    t.string   "last_4"
    t.decimal  "amount",                    :precision => 8, :scale => 2
    t.datetime "created_on"
    t.datetime "updated_on"
    t.date     "billing_period_start_date"
    t.date     "billing_period_end_date"
    t.string   "wh_kind"
    t.datetime "wh_timestamp"
    t.datetime "wh_disbursement_date"
    t.integer  "user_id"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
  end

  add_index "billing_transactions", ["billable_id", "billable_type"], :name => "index_billing_transactions_on_billable_id_and_billable_type"
  add_index "billing_transactions", ["subscription_id"], :name => "index_billing_transactions_on_subscription_id"
  add_index "billing_transactions", ["tenant_id"], :name => "index_billing_transactions_on_tenant_id"
  add_index "billing_transactions", ["user_id"], :name => "index_billing_transactions_on_user_id"

  create_table "blocked_timings", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "calendar_id"
    t.string   "appt_time"
    t.string   "appt_date"
    t.integer  "status",      :default => 1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "blog_details", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "blog_url"
    t.string   "image_url"
    t.date     "post_modified"
    t.integer  "post_id"
    t.boolean  "post_status"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "trash_status",  :default => false
    t.date     "post_created"
  end

  create_table "bonus", :force => true do |t|
    t.integer  "partner_master_id"
    t.integer  "bonus"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "is_paid",           :default => false
  end

  create_table "businesses", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.string   "website"
    t.text     "description"
    t.text     "landmark"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "businesses", ["tenant_id"], :name => "index_businesses_on_tenant_id"

  create_table "calendar_hours", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "calendar_id"
    t.string   "hours_type"
    t.string   "week_days"
    t.string   "start_time"
    t.string   "close_time"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "calendar_hours", ["calendar_id"], :name => "index_calendar_hours_on_calendar_id"
  add_index "calendar_hours", ["tenant_id"], :name => "index_calendar_hours_on_tenant_id"

  create_table "calendars", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.string   "color"
    t.string   "timezone"
    t.string   "apt_length",                          :limit => 4
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "business_id"
    t.string   "google_authentication_token"
    t.string   "google_authentication_refresh_token"
    t.string   "google_authentication_email"
    t.string   "google_authentication_name"
    t.string   "calendar_auth_token"
    t.boolean  "consider_working_hours",                           :default => true
  end

  add_index "calendars", ["tenant_id"], :name => "index_calendars_on_tenant_id"

  create_table "call_charges", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "call_type"
    t.integer  "total_min",                                     :default => 0,     :null => false
    t.integer  "credit_min",                                    :default => 0,     :null => false
    t.integer  "free_min",                                      :default => 0,     :null => false
    t.decimal  "amount",          :precision => 8, :scale => 2
    t.date     "next_due"
    t.string   "transaction_bid"
    t.boolean  "is_paid",                                       :default => false, :null => false
    t.integer  "retry_id"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "call_charges", ["retry_id"], :name => "index_call_charges_on_retry_id"
  add_index "call_charges", ["tenant_id"], :name => "index_call_charges_on_tenant_id"

  create_table "call_details", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "callable_id"
    t.string   "callable_type"
    t.boolean  "record_call",      :default => false, :null => false
    t.string   "account_sid",                         :null => false
    t.string   "call_sid"
    t.string   "status"
    t.string   "call_to"
    t.string   "call_from"
    t.string   "direction"
    t.string   "from_city"
    t.string   "from_country"
    t.string   "from_state"
    t.string   "from_zip"
    t.string   "to_city"
    t.string   "to_country"
    t.string   "to_state"
    t.string   "to_zip"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "duration"
    t.string   "parent_call_sid"
    t.datetime "date_created"
    t.datetime "date_updated"
    t.string   "phone_number_sid"
    t.string   "price"
    t.string   "price_unit"
    t.string   "answered_by"
    t.string   "forwarded_from"
    t.string   "caller_name"
    t.string   "group_sid"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "call_details", ["call_sid"], :name => "index_call_details_on_call_sid"
  add_index "call_details", ["parent_call_sid"], :name => "index_call_details_on_parent_call_sid"
  add_index "call_details", ["phone_number_sid"], :name => "index_call_details_on_phone_number_sid"
  add_index "call_details", ["tenant_id"], :name => "index_call_details_on_tenant_id"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "commissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "partner_master_id"
    t.decimal  "commission",        :precision => 10, :scale => 0
    t.boolean  "is_paid",                                          :default => false
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "adjustment",                                       :default => 0
  end

  create_table "contact_tags", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "contact_id"
    t.integer  "tag_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "contact_tags", ["contact_id"], :name => "index_contact_tags_on_contact_id"
  add_index "contact_tags", ["tag_id"], :name => "index_contact_tags_on_tag_id"
  add_index "contact_tags", ["tenant_id"], :name => "index_contact_tags_on_tenant_id"
  add_index "contact_tags", ["user_id"], :name => "index_contact_tags_on_user_id"

  create_table "contacts", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "status_label_id"
    t.integer  "phone_script_id"
    t.integer  "user_id"
    t.boolean  "via_xps",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "contacts", ["status_label_id"], :name => "index_contacts_on_status_label_id"
  add_index "contacts", ["tenant_id"], :name => "index_contacts_on_tenant_id"
  add_index "contacts", ["user_id"], :name => "index_contacts_on_user_id"

  create_table "credit_amounts", :force => true do |t|
    t.integer  "tenant_id"
    t.decimal  "amount",     :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                         :default => 0, :null => false
    t.integer  "attempts",                         :default => 0, :null => false
    t.text     "handler",    :limit => 2147483647,                :null => false
    t.text     "last_error", :limit => 2147483647
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discount_masters", :force => true do |t|
    t.string   "coupon_code"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.decimal  "percentage",        :precision => 5, :scale => 2
    t.integer  "partner_master_id"
    t.boolean  "active",                                          :default => true, :null => false
    t.string   "duration"
    t.text     "notes"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  add_index "discount_masters", ["partner_master_id"], :name => "index_discount_masters_on_partner_id"

  create_table "email_ids", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "mailable_id"
    t.string   "mailable_type"
    t.string   "emails"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "email_ids", ["mailable_id", "mailable_type"], :name => "index_email_ids_on_mailable_id_and_mailable_type"
  add_index "email_ids", ["tenant_id"], :name => "index_email_ids_on_tenant_id"

  create_table "feedbacks", :force => true do |t|
    t.integer  "tenant_id"
    t.text     "request"
    t.text     "suggestion"
    t.integer  "reason_master_id"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "feedbacks", ["reason_master_id"], :name => "index_feedbacks_on_reason_master_id"
  add_index "feedbacks", ["tenant_id"], :name => "index_feedbacks_on_tenant_id"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "helps", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "user_id"
    t.string   "question"
    t.text     "details"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "area_code"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "helps", ["tenant_id"], :name => "index_helps_on_tenant_id"
  add_index "helps", ["user_id"], :name => "index_helps_on_user_id"

  create_table "notes", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "appointment_id"
    t.integer  "contact_id"
    t.integer  "user_id"
    t.boolean  "via_xps",         :default => false, :null => false
    t.integer  "phone_script_id"
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "notes", ["appointment_id"], :name => "index_notes_on_appointment_id"
  add_index "notes", ["contact_id"], :name => "index_notes_on_contact_id"
  add_index "notes", ["tenant_id"], :name => "index_notes_on_tenant_id"
  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "title"
    t.boolean  "is_read",         :default => false, :null => false
    t.text     "content"
    t.datetime "notify_on"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "notifications", ["notifiable_id", "notifiable_type"], :name => "index_notifications_on_notifiable_id_and_notifiable_type"
  add_index "notifications", ["tenant_id"], :name => "index_notifications_on_tenant_id"

  create_table "partner_helps", :force => true do |t|
    t.integer  "partner_master_id"
    t.text     "details"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "area_code"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "email"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "question"
  end

  create_table "partner_landings", :force => true do |t|
    t.integer  "partner_master_id"
    t.text     "content"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "partner_logos", :force => true do |t|
    t.integer  "partner_master_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "partner_masters", :force => true do |t|
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.boolean  "doc_sign",               :default => false, :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_deleted",             :default => false, :null => false
    t.string   "coupon_code"
  end

  add_index "partner_masters", ["authentication_token"], :name => "index_partner_masters_on_authentication_token", :unique => true
  add_index "partner_masters", ["confirmation_token"], :name => "index_partner_masters_on_confirmation_token", :unique => true
  add_index "partner_masters", ["email"], :name => "index_partner_masters_on_email", :unique => true
  add_index "partner_masters", ["reset_password_token"], :name => "index_partner_masters_on_reset_password_token", :unique => true
  add_index "partner_masters", ["unlock_token"], :name => "index_partner_masters_on_unlock_token", :unique => true

  create_table "partner_payment_informations", :force => true do |t|
    t.integer  "partner_master_id"
    t.string   "paypal_email"
    t.string   "ssn_for_us"
    t.string   "payment_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "ssn_for_non_us"
  end

  create_table "partner_statements", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "partner_stats", :force => true do |t|
    t.string   "ip_address"
    t.integer  "partner_master_id"
    t.integer  "clicks"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "phone_menu_keys", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "phone_menu_id"
    t.string   "digit",         :limit => 6
    t.integer  "routable_id"
    t.string   "routable_type"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "phone_menu_keys", ["phone_menu_id"], :name => "index_phone_menu_keys_on_phone_menu_id"
  add_index "phone_menu_keys", ["tenant_id"], :name => "index_phone_menu_keys_on_tenant_id"

  create_table "phone_menus", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.integer  "business_id"
    t.string   "status"
    t.boolean  "is_deleted",  :default => false, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "phone_menus", ["business_id"], :name => "index_phone_menus_on_business_id"
  add_index "phone_menus", ["tenant_id"], :name => "index_phone_menus_on_tenant_id"

  create_table "phone_numbers", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.string   "area_code",     :limit => 4
    t.string   "phone1",        :limit => 4
    t.string   "phone2",        :limit => 5
    t.integer  "callable_id"
    t.string   "callable_type"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "phone_numbers", ["callable_id", "callable_type"], :name => "index_phone_numbers_on_callable_id_and_callable_type"
  add_index "phone_numbers", ["tenant_id"], :name => "index_phone_numbers_on_tenant_id"

  create_table "phone_script_calls", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "campaign_id"
    t.integer  "total_time",  :default => 0,     :null => false
    t.string   "talk_time"
    t.string   "hold_time"
    t.datetime "call_time"
    t.boolean  "is_read",     :default => false, :null => false
    t.string   "name"
    t.string   "xps_phone"
    t.string   "disposition"
    t.string   "agent_name"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "phone_script_calls", ["tenant_id"], :name => "index_phone_script_calls_on_tenant_id"

  create_table "phone_script_data", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "phone_script_id"
    t.string   "data_key"
    t.string   "data_value"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "phone_script_data", ["phone_script_id"], :name => "index_phone_script_data_on_phone_script_id"
  add_index "phone_script_data", ["tenant_id"], :name => "index_phone_script_data_on_tenant_id"

  create_table "phone_script_hours", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "phone_script_id"
    t.string   "first_mon"
    t.string   "first_tue"
    t.string   "first_wed"
    t.string   "first_thu"
    t.string   "first_fri"
    t.string   "first_sat"
    t.string   "first_sun"
    t.string   "second_mon"
    t.string   "second_tue"
    t.string   "second_wed"
    t.string   "second_thu"
    t.string   "second_fri"
    t.string   "second_sat"
    t.string   "second_sun"
    t.string   "day_status"
    t.boolean  "during_hours_call_center", :default => true, :null => false
    t.boolean  "after_hours_call_center",  :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "phone_script_hours", ["phone_script_id"], :name => "index_phone_script_hours_on_phone_script_id"
  add_index "phone_script_hours", ["tenant_id"], :name => "index_phone_script_hours_on_tenant_id"

  create_table "phone_scripts", :force => true do |t|
    t.integer  "tenant_id"
    t.integer  "business_id"
    t.string   "status"
    t.string   "name"
    t.string   "script_id"
    t.string   "campaign_id"
    t.string   "xps_phone"
    t.string   "when_notify"
    t.integer  "calendar_id"
    t.boolean  "record_call",       :default => false, :null => false
    t.boolean  "is_deleted",        :default => false, :null => false
    t.boolean  "has_audio",         :default => false, :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "script_auth_token"
  end

  add_index "phone_scripts", ["business_id"], :name => "index_phone_scripts_on_business_id"
  add_index "phone_scripts", ["calendar_id"], :name => "index_phone_scripts_on_calendar_id"
  add_index "phone_scripts", ["tenant_id"], :name => "index_phone_scripts_on_tenant_id"

  create_table "reason_masters", :force => true do |t|
    t.text     "reason"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recordings", :force => true do |t|
    t.integer  "tenant_id"
    t.boolean  "is_heard",      :default => false, :null => false
    t.string   "recording_sid",                    :null => false
    t.string   "duration"
    t.string   "call_sid"
    t.datetime "date_created"
    t.datetime "date_updated"
    t.text     "url"
    t.string   "account_sid",                      :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "recordings", ["call_sid"], :name => "index_recordings_on_call_sid"
  add_index "recordings", ["recording_sid"], :name => "index_recordings_on_recording_sid"
  add_index "recordings", ["tenant_id"], :name => "index_recordings_on_tenant_id"

  create_table "role_masters", :force => true do |t|
    t.string   "name"
    t.string   "role_id",    :limit => 3
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "status_labels", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "status_labels", ["tenant_id"], :name => "index_status_labels_on_tenant_id"

  create_table "subscription_logs", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "subscription_bid"
    t.string   "plan_bid"
    t.string   "old_plan_bid"
    t.string   "transaction_bid"
    t.decimal  "balance",          :precision => 8, :scale => 2
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "subscription_logs", ["tenant_id"], :name => "index_subscription_logs_on_tenant_id"

  create_table "subscriptions", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "subscription_bid"
    t.string   "customer_id"
    t.string   "plan"
    t.string   "plan_bid"
    t.string   "status"
    t.integer  "subscribable_id"
    t.string   "subscribable_type"
    t.decimal  "price",                      :precision => 8, :scale => 2
    t.decimal  "balance",                    :precision => 8, :scale => 2
    t.integer  "billing_cycle"
    t.date     "first_billing_date"
    t.date     "next_billing_date"
    t.date     "billing_period_start_date"
    t.date     "billing_period_end_date"
    t.date     "paid_through_date"
    t.decimal  "next_billing_period_amount", :precision => 8, :scale => 2
    t.string   "wh_kind"
    t.datetime "wh_timestamp"
    t.integer  "discount_detail_id"
    t.string   "discount"
    t.integer  "user_id"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  add_index "subscriptions", ["discount_detail_id"], :name => "index_subscriptions_on_discount_detail_id"
  add_index "subscriptions", ["subscribable_id", "subscribable_type"], :name => "index_subscriptions_on_subscribable_id_and_subscribable_type"
  add_index "subscriptions", ["tenant_id"], :name => "index_subscriptions_on_tenant_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "tags", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "color"
  end

  add_index "tags", ["tenant_id"], :name => "index_tags_on_tenant_id"

  create_table "tenant_cancellations", :force => true do |t|
    t.integer  "tenant_id"
    t.text     "suggestion"
    t.integer  "reason_master_id"
    t.text     "suggestion_to_cancel"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "other_reason"
  end

  create_table "tenant_configs", :force => true do |t|
    t.integer  "tenant_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "discount_minutes"
    t.string   "credit_for",       :default => "PhoneScript", :null => false
  end

  create_table "tenant_notifications", :force => true do |t|
    t.integer  "tenant_id"
    t.boolean  "pay_as_you_go", :default => false, :null => false
    t.boolean  "minutes200",    :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "tenant_notifications", ["tenant_id"], :name => "index_tenant_notifications_on_tenant_id"

  create_table "tenants", :force => true do |t|
    t.string   "subdomain"
    t.integer  "call_minutes",        :default => 0,     :null => false
    t.integer  "credit_minutes",      :default => 0,     :null => false
    t.integer  "credit_mail_minutes", :default => 0,     :null => false
    t.integer  "credit_menu_minutes", :default => 0,     :null => false
    t.string   "customer_bid"
    t.boolean  "has_paid",            :default => false, :null => false
    t.string   "subscription_bid"
    t.date     "next_due"
    t.string   "timezone"
    t.string   "status"
    t.string   "plan_bid"
    t.integer  "mail_minutes",        :default => 0,     :null => false
    t.integer  "menu_minutes",        :default => 0,     :null => false
    t.boolean  "from_admin",          :default => false, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.date     "block_date"
  end

  add_index "tenants", ["customer_bid"], :name => "index_tenants_on_customer_bid"
  add_index "tenants", ["subdomain"], :name => "index_tenants_on_subdomain"

  create_table "twilio_numbers", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "phone_line"
    t.string   "friendly_name"
    t.string   "iso_country"
    t.boolean  "toll_free",       :default => false, :null => false
    t.integer  "twilioable_id"
    t.string   "twilioable_type"
    t.string   "capability"
    t.string   "phone_sid"
    t.string   "account_sid"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "twilio_numbers", ["account_sid"], :name => "index_twilio_numbers_on_account_sid"
  add_index "twilio_numbers", ["phone_sid"], :name => "index_twilio_numbers_on_phone_sid", :unique => true
  add_index "twilio_numbers", ["tenant_id"], :name => "index_twilio_numbers_on_tenant_id"
  add_index "twilio_numbers", ["twilioable_id", "twilioable_type"], :name => "index_twilio_numbers_on_twilioable_id_and_twilioable_type"

  create_table "user_notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_notifications", ["notification_id"], :name => "index_unread_notifications_on_notification_id"
  add_index "user_notifications", ["notification_id"], :name => "index_user_notifications_on_notification_id"
  add_index "user_notifications", ["user_id"], :name => "index_unread_notifications_on_user_id"
  add_index "user_notifications", ["user_id"], :name => "index_user_notifications_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "subdomain"
    t.string   "plan_bid"
    t.integer  "role",                   :limit => 2, :default => 0,  :null => false
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",                  :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.string   "status"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["tenant_id"], :name => "index_users_on_tenant_id"

  create_table "voicemails", :force => true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.integer  "business_id"
    t.string   "status"
    t.boolean  "is_deleted",  :default => false, :null => false
    t.boolean  "transcribe",  :default => false, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "voicemails", ["business_id"], :name => "index_voicemails_on_business_id"
  add_index "voicemails", ["tenant_id"], :name => "index_voicemails_on_tenant_id"

end
