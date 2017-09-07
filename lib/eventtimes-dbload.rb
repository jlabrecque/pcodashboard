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
datestamp = Time.now
set_endtime()


puts "============================================================="
puts "eventtime_dbload.rb is a Ruby script to load the current "
puts "Planning Center eventtime data within the churches account"
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

next_check = 0
while !next_check.nil?
    evt = eventtimes(page_size,offset_index)
    next_check = evt["links"]["next"]
    inner_loop_index = 0
    # per event loop
    evt["data"].each do |u|
        evtcheck = Eventtime.where(:eventtime_id_pco => u["id"])
        if !evtcheck.exists?
          puts "Creating new record: Eventtime- #{u["id"]}"
          # stuff the people array with required field data
            eventtimerecord = Eventtime.create(
                 :eventtime_id_pco  => u["id"],
                 :event_id_pco      => u["relationships"]["event"]["data"]["id"],
                 :starts_at         => u["attributes"]["starts_at"],
                 :guest_count       => u["attributes"]["guest_count"],
                 :regular_count     => u["attributes"]["regular_count"],
                 :volunteer_count   => u["attributes"]["volunteer_count"]
            )
            totcreated += 1
        elsif  !(evtcheck[0].updated_at == u["attributes"]["updated_at"])
          puts "Updating existing record: Eventtime- #{u["id"]}"
          # stuff the people array with required field data
            eventtimerecord = Eventtime.update(evtcheck[0]["id"],
                  :eventtime_id_pco  => u["id"],
                  :event_id_pco      => u["relationships"]["event"]["data"]["id"],
                  :starts_at         => u["attributes"]["starts_at"],
                  :guest_count       => u["attributes"]["guest_count"],
                  :regular_count     => u["attributes"]["regular_count"],
                  :volunteer_count   => u["attributes"]["volunteer_count"]
             )
        else
          puts "*** No action ***"
        end
    inner_loop_index = 0
 end
 offset_index += page_size
end
puts "** ALl records processed  **"
puts "Total created: #{totcreated}"

Eventtime.all.each do |evt|
    ev = Event.where(:event_id_pco => evt["event_id_pco"])
    puts "Updating dB Eventtime #{evt.id}"
    evt.update(:event_id => ev[0].id )
end
