module GoogleSync
  
  def periodically_sync_google_calendar
    Tenant.active_tenants_only.each do |tenant|
      tenant.calendars.synked_with_google.each do |calendar|
        tenant.users.each do |user|
          queue = 'sync_' + calendar.tenant_id.to_s + '_' + calendar.id.to_s
          Appointment.delay(:queue => queue).sync_google_calendar(calendar.google_authentication_token, calendar.google_authentication_refresh_token, tenant.id, calendar, user)
        end
      end
    end
  end

end