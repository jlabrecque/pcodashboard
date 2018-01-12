require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'
require 'dotenv'
require 'dotenv-rails'
require 'calendar_methods.rb'

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

# Load Row Header global to all records
@calendar,lastsunday = get_calendar()

week1     = (lastsunday.to_date - 119).strftime("%m/%d")
week2     = (lastsunday.to_date - 112).strftime("%m/%d")
week3     = (lastsunday.to_date - 105).strftime("%m/%d")
week4     = (lastsunday.to_date - 98).strftime("%m/%d")
week5     = (lastsunday.to_date - 91).strftime("%m/%d")
week6     = (lastsunday.to_date - 84).strftime("%m/%d")
week7     = (lastsunday.to_date - 77).strftime("%m/%d")
week8     = (lastsunday.to_date - 70).strftime("%m/%d")
week9     = (lastsunday.to_date - 63).strftime("%m/%d")
week10    = (lastsunday.to_date - 56).strftime("%m/%d")
week11    = (lastsunday.to_date - 49).strftime("%m/%d")
week12    = (lastsunday.to_date - 42).strftime("%m/%d")
week13    = (lastsunday.to_date - 35).strftime("%m/%d")
week14    = (lastsunday.to_date - 28).strftime("%m/%d")
week15    = (lastsunday.to_date - 21).strftime("%m/%d")
week16    = (lastsunday.to_date - 14).strftime("%m/%d")
week17    = (lastsunday.to_date - 7).strftime("%m/%d")
week18    = (lastsunday.to_date - 0).strftime("%m/%d")


# Load per person checkin grid

LOGGER.info("Writing Checkin grid updates to Person table...")

Person.all.each do |person|
    @calendar,lastsunday = get_calendar()
    stuff_checkins(person.pco_id,@calendar)
    week1checkin = @calendar[(lastsunday.to_date - 119).strftime("%Y%m%d")][:attend]
    week2checkin  = @calendar[(lastsunday.to_date - 112).strftime("%Y%m%d")][:attend]
    week3checkin  = @calendar[(lastsunday.to_date - 105).strftime("%Y%m%d")][:attend]
    week4checkin  = @calendar[(lastsunday.to_date - 98).strftime("%Y%m%d")][:attend]
    week5checkin  = @calendar[(lastsunday.to_date - 91).strftime("%Y%m%d")][:attend]
    week6checkin  = @calendar[(lastsunday.to_date - 84).strftime("%Y%m%d")][:attend]
    week7checkin  = @calendar[(lastsunday.to_date - 77).strftime("%Y%m%d")][:attend]
    week8checkin  = @calendar[(lastsunday.to_date - 70).strftime("%Y%m%d")][:attend]
    week9checkin  = @calendar[(lastsunday.to_date - 63).strftime("%Y%m%d")][:attend]
    week10checkin = @calendar[(lastsunday.to_date - 56).strftime("%Y%m%d")][:attend]
    week11checkin = @calendar[(lastsunday.to_date - 49).strftime("%Y%m%d")][:attend]
    week12checkin = @calendar[(lastsunday.to_date - 42).strftime("%Y%m%d")][:attend]
    week13checkin = @calendar[(lastsunday.to_date - 35).strftime("%Y%m%d")][:attend]
    week14checkin = @calendar[(lastsunday.to_date - 28).strftime("%Y%m%d")][:attend]
    week15checkin = @calendar[(lastsunday.to_date - 21).strftime("%Y%m%d")][:attend]
    week16checkin = @calendar[(lastsunday.to_date - 14).strftime("%Y%m%d")][:attend]
    week17checkin = @calendar[(lastsunday.to_date - 7).strftime("%Y%m%d")][:attend]
    week18checkin = @calendar[(lastsunday.to_date - 0).strftime("%Y%m%d")][:attend]

Person.update(person.id,
  :week1          => week1,
  :week1checkin   => week1checkin,
  :week2          => week2,
  :week2checkin   => week2checkin,
  :week3          => week3,
  :week3checkin   => week3checkin,
  :week4          => week4,
  :week4checkin   => week4checkin,
  :week5          => week5,
  :week5checkin   => week5checkin,
  :week6          => week6,
  :week6checkin   => week6checkin,
  :week7          => week7,
  :week7checkin   => week7checkin,
  :week8          => week8,
  :week8checkin   => week8checkin,
  :week9          => week9,
  :week9checkin   => week9checkin,
  :week10         => week10,
  :week10checkin  => week10checkin,
  :week11         => week11,
  :week11checkin  => week11checkin,
  :week12         => week12,
  :week12checkin  => week12checkin,
  :week13         => week13,
  :week13checkin  => week13checkin,
  :week14         => week14,
  :week14checkin  => week14checkin,
  :week15         => week15,
  :week15checkin  => week15checkin,
  :week16         => week16,
  :week16checkin  => week16checkin,
  :week17         => week17,
  :week17checkin  => week17checkin,
  :week18         => week18,
  :week18checkin  => week18checkin
)
end

LOGGER.info("SCRIPT COMPLETED SUCCESSFULLY")
if !File.readlines(logfile).grep(/SCRIPT COMPLETED SUCCESSFULLY/).any?
  LOGGER.info("Script execution failed!")
  eml_body = File.read(logfile)
  LOGGER.info("Emailing log file to #{eml_address}")
  PcocoreMailer.send_email("",eml_address,eml_subject,eml_body).deliver
end
