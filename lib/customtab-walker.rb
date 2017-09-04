require 'rubygems'
require 'pp'
require 'date'
require 'pco_api'
require 'json'
require 'dotenv'
require 'dotenv-rails'
require 'graticule'



api = PCO::API.new(basic_auth_token: ENV['PCOAUTHTOK'], basic_auth_secret: ENV['PCOAUTHSEC'] )

  tabs_unp = api.people.v2.tabs.get()
  tabs = JSON.parse(tabs_unp.to_json)

tabs["data"].each do |t|
  puts "====Tab_Id:#{t["id"]}  Name:#{t["attributes"]["name"]}"
  field_definitions_unp = api.people.v2.tabs[t["id"]].get(include: 'field_definitions')
  field_definitions = JSON.parse(field_definitions_unp.to_json)
  field_definitions["included"].each do |fd|
      puts "========** FD_Id:#{fd["id"]}  Type:#{fd["attributes"]["data_type"]}  Name:#{fd["attributes"]["name"]}"
      field_options_unp = api.people.v2.field_definitions[fd["id"]].field_options.get()
      field_options = JSON.parse(field_options_unp.to_json)
      field_options["data"].each do |fo|
        puts "========**====== Value:#{fo["attributes"]["value"]}"
      end
  end
end
