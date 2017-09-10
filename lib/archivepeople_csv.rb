require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'


#CONSTANTS
offset_index = 0
page_size = 50
sleepval = 10

#Start ...
puts "Starting processing..."
ppl = people(page_size,offset_index)
#check for the existence of a next link (ie not at end of checkins)
next_check = ppl["links"]["next"]

puts "Opening CSV file for write..."

#Open CSV for writing
#CSV.open("check_ins_013017.csv","w") do |csv|
#CSV.open("./public/check_ins_#{Date.today.strftime("%m%e%y")}.csv","w") do |csv|

#Insert CSV Header -- 4 fields
#csv << ["CheckinID","Name","Type","CheckinDate"]
#if next exists (not at end)...
  while !next_check.nil?

    #do API get, convert to JSON
    puts "Processing offset: #{offset_index}"
    ppl = people(page_size,offset_index)
    next_check = ppl["links"]["next"]

    inner_loop_index = 0
    ppl["data"].each do |u|
      peopleapp_link = "https://people.planningcenteronline.com/people/AC"+ppl["data"][inner_loop_index]["id"]
      # single person pull
      prs = person()
      person_array = JSON.parse(api.people.v2.people[people["data"][inner_loop_index]["id"]].get(include: 'emails,phone_numbers,addresses').to_json)


      email = JSON.parse(person_array["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0].nil? ? "na" : JSON.parse(person_array["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["address"]
      phone = JSON.parse(person_array["included"].select {|k| k["type"] == "PhoneNumber"}[0].to_json).nil? ? "" : JSON.parse(person_array["included"].select {|k| k["type"] == "PhoneNumber"}[0].to_json)["attributes"]["number"]
      if JSON.parse(person_array["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0].nil?
          street = ""
          city = ""
          state = ""
          zip = ""
      else
          street = JSON.parse(person_array["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["street"]
          city = JSON.parse(person_array["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["city"]
          state = JSON.parse(person_array["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["state"]
          zip = JSON.parse(person_array["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["zip"]

      end

          # stuff the people array with required field data
          person = [people["data"][inner_loop_index]["id"],
                    people["data"][inner_loop_index]["attributes"]["last_name"],
                    people["data"][inner_loop_index]["attributes"]["first_name"],
                    people["data"][inner_loop_index]["attributes"]["middle_name"],
                    people["data"][inner_loop_index]["attributes"]["nickname"],
                    email,
                    phone,
                    people["data"][inner_loop_index]["attributes"]["gender"],
                    people["data"][inner_loop_index]["attributes"]["birthdate"],
                    people["data"][inner_loop_index]["attributes"]["membership"],
                    street, city, state, zip,
                    people["data"][inner_loop_index]["attributes"]["created_at"],
                    people["data"][inner_loop_index]["attributes"]["updated_at"]
                  ]
          #  csv = [people["data"][inner_loop_index]["id"].delete('"'),name.delete('"'),people["data"][inner_loop_index]["attributes"]["kind"].delete('"'),people["data"][inner_loop_index]["attributes"]["created_at"][0..9].delete('"')]

            inner_loop_index += 1

            #puts email_array["data"].nil?
            pp person
            #puts phone
            #puts inner_loop_index
            #puts offset_index

    end
   offset_index += page_size
   puts "Sleeping #{sleepval} seconds"
   sleep(sleepval)
  end
#end
# puts "** ALl records processed -- CSV file complete **"
