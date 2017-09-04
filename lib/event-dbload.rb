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


puts "============================================================="
puts "event_dbload.rb is a Ruby script to load the current "
puts "Planning Center event data within the churches account"
puts "using the PCO API. The script checks the API collected data "
puts "against the current local database data, creates new records"
puts "when they dont exist, update if record has been updated since"
puts "the last API pull, and skips duplicates"
puts " "
puts "Planning Center rate limits API pulls to 100 per minute, so"
puts "the script also counts the API pulls against a 1 minute"
puts "counter, and if approach the rate limit, will sleep the"
puts "script to keep within the limit"
puts "============================================================="

puts "Starting processing..."
#get block
ev = events()

    inner_loop_index = 0
    # per event loop
    ev["data"].each do |u|
        evcheck = Event.where(:event_id => u["id"])
        if !evcheck.exists?
          puts "Creating new record"
          # stuff the people array with required field data
            eventrecord = Event.create(
                :event_id  => u["id"],
                :event_name  => u["attributes"]["name"],
                :event_updated_at  => u["attributes"]["updated_at"]
            )
            totcreated += 1
        elsif  !(evcheck[0].event_updated_at == u["attributes"]["updated_at"])
          puts "Updating existing record"
          # stuff the people array with required field data
          eventrecord = Event.update(
          :event_id  => u["id"],
          :event_name  => u["attributes"]["name"],
          :event_updated_at  => u["attributes"]["updated_at"]
          )
        else
          puts "*** No action ***"
        end
    inner_loop_index = 0
 end
puts "** ALl records processed  **"
puts "Total created: #{totcreated}"
