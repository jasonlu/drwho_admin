# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Admin.create({ :email => "admin@onlynet.biz",  :password => 'P@ssw0rd',  :password_confirmation => 'P@ssw0rd', :roles => ['admin'] } , :without_protection => true)
Page.create({:key => "one_on_one", :title => "one_on_one", :body => ""})
Page.create({:key => "faq", :title => "faq", :body => ""})
Page.create({:key => "contact_us", :title => "contact_us", :body => ""})