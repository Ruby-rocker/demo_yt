# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#set :output, {:standard => 'cron.log'}
set :output, "#{path}/log/cron.log"
#set :environment, 'development'

# every 1.minutes do
#  # runner "Business.test_rake"
#  rake 'connect_remote_mysql'
# end
#
#every 10.minutes do
#  runner "Business.test_rake"
#  rake 'get_call_center_number'
#end

#every :hour do
every 15.minutes do
  runner "CallCenter::XpsUsa.get_forwarding_number"
end

every :day, :at => '8:30am' do
  runner "CallCenter::XpsUsa.get_call_records"
end

every :day, :at => '10:00pm' do
  runner "CallChargesConfigure.daily_charge"
end

every :day, :at => '11:00pm' do
  runner "CallChargesConfigure.overage_charge"
  #runner "TalkTimeCharges.daily_charge"
  #runner "CallTransaction.execute"
end

# every 1.minutes do
#   runner "Appointment.sync_google_calendar(token, refresh_token)"
# end

#############################
#https://github.com/javan/whenever/issues/295
#https://addons.heroku.com/scheduler
#whenever --update-crontab
#crontab -l
#Simply running the whenever command by itself will only show you the schedule in cron format.
#############################
