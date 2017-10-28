require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'
require 'dotenv'
require 'dotenv-rails'

#CONSTANTS
logfile_prefix = "checkins"
datestamp = Time.now
set_endtime()
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"


LOGGER = Log4r::Logger.new('Checkins_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)


LOGGER.info("=============================================================")
LOGGER.info("checkins_dbload.rb is a Ruby script to load the current ")
LOGGER.info("Planning Center CheckIn data within the churches account")
LOGGER.info("using the PCO API. The script checks the API collected data ")
LOGGER.info("against the current local database data, creates new records")
LOGGER.info("when they dont exist, update if record has been updated since")
LOGGER.info("the last API pull, and skips duplicates")
LOGGER.info(" ")
LOGGER.info("The script also creates a summary records under")
LOGGER.info("CheckInMeta recording the total created, updated and date")
LOGGER.info(" ")
LOGGER.info("Planning Center rate limits API pulls to 100 per minute, so")
LOGGER.info("the script also counts the API pulls against a 1 minute")
LOGGER.info("counter, and if approach the rate limit, will sleep the")
LOGGER.info("script to keep within the limit")
LOGGER.info("=============================================================")

##Update Events

#CONSTANTS
offset_index = 0
page_size = 50
sleepval = 30
totprocessed = 0
totcreated = 0
totupdated = 0
$pullcount = 0


LOGGER.info("Creating/Updating Events...")
#get block
ev = events()

    inner_loop_index = 0
    # per event loop
    ev["data"].each do |u|
        evcheck = Event.where(:event_id_pco => u["id"])
        if !evcheck.exists?
          # stuff the people array with required field data
            eventrecord = Event.create(
                :event_id_pco  => u["id"],
                :event_name  => u["attributes"]["name"],
                :event_updated_at  => u["attributes"]["updated_at"],
                :frequency        =>  u["attributes"]["frequency"]
            )
            totcreated += 1
        elsif  !(evcheck[0].event_updated_at == u["attributes"]["updated_at"])
          # stuff the people array with required field data
          eventrecord = Event.update(
                :event_id_pco  => u["id"],
                :event_name  => u["attributes"]["name"],
                :event_updated_at  => u["attributes"]["updated_at"],
                :frequency        =>  u["attributes"]["frequency"]
          )
        else
        end
    inner_loop_index = 0
 end
LOGGER.info("** All Event records processed  **")
LOGGER.info("Total Events created: #{totcreated}")

##Update EventTimes

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

LOGGER.info("Creating/Updating EventTimes...")

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
        end
    inner_loop_index = 0
 end
 offset_index += page_size
end
LOGGER.info("** All EventTime records processed  **")
LOGGER.info("Total EventTimes created: #{totcreated}")

# LOGGER.info("Updating Eventime Associations")

# Eventtime.all.each do |evt|
#     ev = Event.where(:event_id_pco => evt["event_id_pco"])
#     puts "1"
#     evt.update(:event_id => ev[0].id )
# end

# LOGGER.info("Updating Eventime Associations")
##Update CheckIns

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1 and ARGV.first == "update"
        LOGGER.info("Performing full update, checking all records for updates")
        offset_index = 0
  else
        precheckinmeta = Metum.checkins.last
        !precheckinmeta.nil? ? offset_index = precheckinmeta.last_offset : offset_index = 0
        LOGGER.info("Performing delta update, based on last offset completed: #{offset_index}")
  end

  #Creating new tracking meta
  meta = Metum.create(:modeltype => "checkins",
  :total_created => 0,
  :last_id_imported => 0,
  :last_offset => offset_index)

#CONSTANTS
page_size = 100
sleepval = 0
lastcheckinid = ""
logfile_prefix = "checkins"
totcreated = 0
totupdated = 0
next_check = 0
$pullcount = 0
datestamp = Time.now
set_endtime()
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER.info("Last offset processed: #{offset_index}")
LOGGER.info("Creating/Updating Checkins...")
  while !next_check.nil?
    # pull groups of records each loop
    checkinblock = checkins(page_size,offset_index)
    next_check = checkinblock["links"]["next"]
    # per person loop
    checkinblock["data"].each do |checkin|
      checkid = checkin["id"]
      chk = check(checkid)
      checkincheck = CheckIn.where(:checkin_id_pco => chk["data"]["id"])
         # If exists
                   if !checkincheck.exists?
      #             ## then do all this to create new record
                    @pco_id = chk["data"]["relationships"]["person"]["data"].nil? ? "" : chk["data"]["relationships"]["person"]["data"]["id"]
                    @location = chk["data"]["relationships"]["location"]["data"].nil? ? "" : chk["data"]["relationships"]["location"]["data"]["id"]
                    @eventtime_id_pco = chk["data"]["relationships"]["event_times"]["data"][0].nil? ? "" : chk["data"]["relationships"]["event_times"]["data"][0]["id"]
      #               # checkin_id not in db, so use create
                     LOGGER.info("Creating new record for Checkin ID #{checkid} #{offset_index}")
                     checkinnew = CheckIn.create(
                      :eventtime_id_pco       => @eventtime_id_pco,
                      :checkin_id_pco         => chk["data"]["id"],
                      :checkin_time           => chk["data"]["attributes"]["updated_at"],
                      :checkin_updated_at     => chk["data"]["attributes"]["updated_at"],
                      :checkin_kind           => chk["data"]["attributes"]["kind"],
                      :first_name             => chk["data"]["attributes"]["first_name"],
                      :last_name              => chk["data"]["attributes"]["last_name"],
                      :pco_id                 => @pco_id,
                      :location               => @location
                      )
                     totcreated += 1
                   elsif  !(checkincheck[0].checkin_updated_at == chk["data"]["attributes"]["updated_at"])
                     LOGGER.info("Updating record for Checkin ID #{checkid} #{offset_index}")
                     checkinnew = CheckIn.update(checkincheck[0].id,
                      :eventtime_id_pco       => chk["data"]["relationships"]["event_times"]["data"][0]["id"],
                      :checkin_id_pco         => chk["data"]["id"],
                      :checkin_time           => chk["data"]["attributes"]["updated_at"],
                      :checkin_updated_at     => chk["data"]["attributes"]["updated_at"],
                      :checkin_kind           => chk["data"]["attributes"]["kind"],
                      :first_name             => chk["data"]["attributes"]["first_name"],
                      :last_name              => chk["data"]["attributes"]["last_name"],
                      :pco_id                 => @pco_id,
                      :location               => @location
                      )
                     totupdated += 1
                   else
                 end
      # lastcheckinid = checkid
    end
    last_offset_index = offset_index
    offset_index += page_size
    LOGGER.info("New Offset: #{offset_index}")

    meta = Metum.update(meta.id,
    :total_created => totcreated,
    :total_updated => totupdated,
    :total_processed => totcreated + totupdated,
    :last_offset => last_offset_index)
  end
LOGGER.info("** All records processed **")
LOGGER.info("Total created: #{totcreated}")
LOGGER.info("Total created: #{totupdated}")
LOGGER.info("=============================================================")
LOGGER.info("Script ended at #{datestamp}")
LOGGER.info("=============================================================")

# #Update all Checkins for association
LOGGER.info("Updating :person_id associations from Person dB...")
#CheckIn.where(:person_id => nil).each do |chk|
CheckIn.all.each do |chk|
     p = Person.where(:pco_id => chk.pco_id)
     if p.count > 0 # matching pco_ids
        chk.update(:person_id => p[0].id)
     end
end
LOGGER.info("Updating :eventtime_id associations from Eventtime dB...")

CheckIn.where(:eventtime_id => nil).each do |chk|
     e = Eventtime.where(:eventtime_id_pco => chk.eventtime_id_pco)
     if e.count > 0  #matching eventime_ids
        chk.update(:eventtime_id => e[0].id, :checkin_time => e[0].starts_at)
     end
end


eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
