#app/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "#{APP_CONFIG['google_oauth2']['client_id']}", "#{APP_CONFIG['google_oauth2']['client_secret']}", {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar',
    redirect_uri: "#{APP_CONFIG['site_url']}auth/google_oauth2/callback"
  }
end