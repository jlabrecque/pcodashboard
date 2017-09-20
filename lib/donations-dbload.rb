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
lastdonationid = ""
more = 0
total = 0
logfile_prefix = "donations"
totcreated = 0
totupdated = 0
next_check = 0
$pullcount = 0
datestamp = Time.now
set_endtime()
pacing = 2 # numbe of seconds between api calls, to reduce iowait load during updates
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('Donations_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1 and ARGV.first == "update"
        LOGGER.info("Performing full update, checking all records for updates")
        offset_index = 0
  else
        predonationmeta = Metum.donations.last
        !predonationmeta.nil? ? offset_index = predonationmeta.last_offset : offset_index = 0
        LOGGER.info("Performing delta update, based on last offset completed: #{offset_index}")
  end

LOGGER.info("=============================================================")
LOGGER.info("donations_dbload.rb is a Ruby script to load the current ")
LOGGER.info("Planning Center Donation data within the churches account")
LOGGER.info("using the PCO API. The script checks the API collected data ")
LOGGER.info("against the current local database data, creates new records")
LOGGER.info("when they dont exist, update if record has been updated since")
LOGGER.info("the last API pull, and skips duplicates")
LOGGER.info(" ")
LOGGER.info("The script also creates a summary records under")
LOGGER.info("DonationMetum recording the total created, updated and date")
LOGGER.info(" ")
LOGGER.info("Planning Center rate limits API pulls to 100 per minute, so")
LOGGER.info("the script also counts the API pulls against a 1 minute")
LOGGER.info("counter, and if approach the rate limit, will sleep the")
LOGGER.info("script to keep within the limit")
LOGGER.info("=============================================================")
LOGGER.info("Last offset processed: #{offset_index}")

#Creating new tracking meta
meta = Metum.create(:modeltype => "donations",
:total_created => 0,
:last_id_imported => 0,
:last_offset => offset_index)

while !next_check.nil?
  don = donations(page_size,offset_index)
  next_check = don["links"]["next"]
  donations_data = don["data"]
  donations_data.each do |dd|
    donation_id         =   dd['id']
    !dd['relationships']['person']['data'].nil? ? pco_id  = dd['relationships']['person']['data']['id'] : pco_id = "000000"
    amount_cents        =   dd['attributes']['amount_cents']
    donation_created_at =   dd['attributes']['created_at']
    donation_updated_at =   dd['attributes']['updated_at']
    payment_channel     =   dd['attributes']['payment_channel']
    payment_method      =   dd['attributes']['payment_method']
    payment_method_sub  =   dd['attributes']['payment_method_sub']
    designations(donation_id)["data"].each do |des|
            des_id = des["id"]
            des_amount = des["attributes"]["amount_cents"]
            fund_id = des["relationships"]["fund"]["data"]["id"]
            designationscheck = Donation.where(:designation_id => des_id)

            if !designationscheck.exists?
              ## then do all this to create new record
              LOGGER.info("Creating new record for Donation ID #{donation_id} #{des_id} #{pco_id} Offset: #{offset_index} ")
              # stuff the people array with required field data

              donationnew = Donation.create(
              :donation_id            =>  donation_id,
              :amount_cents           =>  des_amount,
              :donation_created_at    =>  donation_created_at,
              :donation_updated_at    =>  donation_updated_at,
              :payment_channel        =>  payment_channel,
              :payment_method         =>  payment_method,
              :payment_method_sub     =>  payment_method_sub,
              :designation_id         =>  des_id,
              :designation_cents      =>  des_amount,
              :fund_id                =>  fund_id,
              :pco_id                 =>  pco_id
              )

              totcreated += 1
                # pco_id not in db, so use create
            elsif  !(designationscheck[0].donation_updated_at == donation_updated_at)

              LOGGER.info("Updating new record for Donation ID #{donation_id} #{des_id} #{pco_id} Offset: #{offset_index} ")
              donationexist = Donation.update(designationscheck[0].id,
              :donation_id            =>  donation_id,
              :amount_cents           =>  des_amount,
              :donation_created_at    =>  donation_created_at,
              :donation_updated_at    =>  donation_updated_at,
              :payment_channel        =>  payment_channel,
              :payment_method         =>  payment_method,
              :payment_method_sub     =>  payment_method_sub,
              :designation_id         =>  des_id,
              :designation_cents      =>  des_amount,
              :fund_id                =>  fund_id,
              :pco_id                 =>  pco_id
              )
              totupdated += 1
            else
              LOGGER.info("No action for Donation ID #{donation_id} #{des_id} #{pco_id} Offset: #{offset_index}  ")
            end
            sleep(pacing) #let the process breath.... breath.....

        end
        lastdonationid = donation_id

    end
    last_index = offset_index
    offset_index += page_size
    meta = Metum.update(meta.id,
    :total_created => totcreated,
    :total_updated => totupdated,
    :total_processed => totcreated + totupdated,
    :last_offset => offset_index)
end
LOGGER.info("** All records processed **")
LOGGER.info("Total created: #{totcreated}")
LOGGER.info("=============================================================")
LOGGER.info("Script ended at #{datestamp}")
LOGGER.info("=============================================================")
#open_log.close
LOGGER.info("Updating :person_id associations from Person dB...")
Donation.all.each do |don|
     p = Person.where(:pco_id => don.pco_id)
     if p.count > 0 # matching pco_ids
        puts "Updating person_id for Donation #{don.id}"
        don.update(:person_id => p[0].id)
     else
        puts "No associated PCO ID -- skipping"
     end
end

eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
