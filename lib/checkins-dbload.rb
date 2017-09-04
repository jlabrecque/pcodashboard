require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'
require 'dotenv'
require 'dotenv-rails'
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

LOGGER = Log4r::Logger.new('Checkins_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1 and ARGV.first == "update"
        LOGGER.info("Performing full update, checking all records for updates")
        offset_index = 0
  else
        precheckinmeta = Metum.checkins.last
        !precheckinmeta.nil? ? offset_index = precheckinmeta.last_offset : offset_index = 0
        LOGGER.info("Performing delta update, based on last offset completed: #{offset_index}")
  end

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
LOGGER.info("Last offset processed: #{offset_index}")
LOGGER.info("Starting processing...")
#OUTER LOOP - per page size (ie 25, 50 records)
#if next exists (not at end)...
  while !next_check.nil?
    # pull groups of records each loop
    checkinblock = checkins(page_size,offset_index)
    next_check = checkinblock["links"]["next"]
# Inner loop
    inner_loop_index = 0
    # per person loop
    checkinblock["data"].each do |checkin|
        checkid = checkinblock["data"][inner_loop_index]["id"]
        checkin = check(checkid)
        checkincheck = CheckIn.where(:checkin_id => checkin["data"]["id"])
        # If exists
                  if !checkincheck.exists?
                  ## then do all this to create new record
                  @person = checkin["data"]["relationships"]["person"]["data"].nil? ? "" : checkin["data"]["relationships"]["person"]["data"]["id"]
                  @location = checkin["data"]["relationships"]["location"]["data"].nil? ? "" : checkin["data"]["relationships"]["location"]["data"]["id"]
                  @event = checkin["data"]["relationships"]["event"]["data"].nil? ? "" : checkin["data"]["relationships"]["event"]["data"]["id"]
                    # checkin_id not in db, so use create
                    LOGGER.info("Creating new record for Checkin ID #{checkid} #{offset_index}")
                    checkinnew = CheckIn.create(
                    :checkin_id             => checkid,
                    :checkin_time           => checkin["data"]["attributes"]["updated_at"],
                    :checkin_kind           => checkin["data"]["attributes"]["kind"],
                    :first_name             => checkin["data"]["attributes"]["first_name"],
                    :last_name              => checkin["data"]["attributes"]["last_name"],
                    :pco_id                 => @person,
                    :event                  => @event,
                    :location               => @location
                    )
                    totcreated += 1
                  else
                  LOGGER.info("No action for CheckIn ID #{checkid}  #{offset_index}")
                end
      lastcheckinid = checkid
      inner_loop_index += 1
    end
    last_index = offset_index
    offset_index += page_size
  end
LOGGER.info("** All records processed **")
LOGGER.info("Total created: #{totcreated}")
LOGGER.info("=============================================================")
LOGGER.info("Script ended at #{datestamp}")
LOGGER.info("=============================================================")
#Write checkinmeta record
postcheckinmeta = Metum.create(
    :modeltype => "checkins",
    :total_created => totcreated,
    :last_id_imported => lastcheckinid,
    :last_offset => last_index)
eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
