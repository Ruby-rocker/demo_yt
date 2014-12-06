# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#RoleMaster.find_or_create_by_name!(name:'owner', role_id: 1)
#RoleMaster.find_or_create_by_name!(name:'admin', role_id: 2)
#RoleMaster.find_or_create_by_name!(name:'staff', role_id: 3)
#RoleMaster.find_or_create_by_name!(name:'call_center', role_id: 4)
#
#puts "Roles created"
#

#Tenant.create!(subdomain: 'staging', status: 'active')
ActiveRecord::Base.connection.execute "truncate reason_masters"

ReasonMaster.create(reason: "Don't need it for awhile, but I'll be back")
ReasonMaster.create(reason: "Just not using the service enough")
ReasonMaster.create(reason: "Issues with call quality")
ReasonMaster.create(reason: "Issue with customer service")
ReasonMaster.create(reason: "Other")