require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'dotenv'
require 'dotenv-rails'


Person.all.each do |p|
  fullname = "#{p.first_name} #{p.last_name}"
  puts fullname
  personup = Person.update(p.id,
  :fullname          => fullname
  )

end
puts "Done!"
