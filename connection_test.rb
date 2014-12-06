require 'rubygems'
require 'active_record'
puts "=======RAKE TASK TEST=====start===#{Time.now}==="
  # client = Mysql2::Client.new(:host => "192.168.3.8", :username => "root", :database => "yestrak", :password => "password")
  client = ActiveRecord::Base.establish_connection(
    :host => "localhost",
    :port => 22,
    :adapter  => "mysql2",
    :database => "yestrakmarketingsite",
    :username => "root",
    :password => "XbqnobDCzE5Z"
	)
  p client.connection.execute("SELECT * FROM wp_users")

  puts "=======RAKE TASK TEST=====end====#{Time.now}=="