require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'

#CONSTANTS
offset_index = 0
page_size = 50
sleepval = 30
totprocessed = 0
totcreated = 0
totupdated = 0
$pullcount = 0

#Start ...
puts "Starting processing..."
st = service_type()
    inner_loop_index = 0
    st["data"].each do |u|

      stcheck = ServiceType.where(:stid => u["id"])

# If exists
        if !stcheck.exists?
            puts "Creating new record"
            servicepost = ServiceType.create(
            :stid           =>  u["id"],
            :st_name        =>  u["attributes"]["name"],
            :st_updated_at  =>  u["attributes"]["updated_at"],
            :st_freq        =>  u["attributes"]["frequency"]
            )
            totcreated += 1


        elsif  !(stcheck[0].st_updated_at == st["data"][inner_loop_index]["attributes"]["updated_at"])
          puts "Updating existing record"

          servicepost = ServiceType.update(stcheck[0].id,
          :stid             =>  u["id"],
          :st_name          =>  u["attributes"]["name"],
          :st_updated_at    =>  u["attributes"]["updated_at"],
          :st_freq          =>  u["attributes"]["frequency"]
          )
        else
          puts "*** No action ***"
        end
            inner_loop_index += 1

    end
puts "** All records processed  **"
puts "Total created: #{totcreated}"
