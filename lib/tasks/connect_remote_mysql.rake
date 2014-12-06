desc 'RAKE connection_to_remote_mysql_server TASK'
task :connect_remote_mysql do
  puts "=======RAKE TASK CONNECTION=====start===#{Time.now}==="
  # client = Mysql2::Client.new(:host => "192.168.3.8", :username => "root", :database => "yestrak", :password => "password")
  client = ActiveRecord::Base.establish_connection(
    :host => "localhost",
    :port => 22,
    :adapter  => "mysql2",
    :database => "yestrakmarketingsite",
    :username => "root",
    :password => "XbqnobDCzE5Z"
	)
  # users = client.query("SELECT * FROM users")
  p client.connection.execute("SELECT * FROM wp_users")
  #uri = URI.parse('http://vizicall.xpsusa.com/vizicall.asmx/GetForwardingNumber')
  #param_hash={APIUserName:'ViziCallAPIUser',APIPassword:'ViziCall23125!',CampaignID:30145}
  #res = Net::HTTP.post_form(uri,param_hash)
  #Hash.from_xml(res.body)["ForwardingNumber"]["FordwardingNumber"]

  puts "=======RAKE TASK CONNECTION=====end====#{Time.now}=="
end

# This job is run at 00:00:00 CDT. Hence conversations having end_date in CDT will correctly end at 00:00:00.
# If the conversation had stored the end date in PST, at 00:00 CDT, there would be still 2 hours left for it to end. Hence this conversation will end during the next task run.