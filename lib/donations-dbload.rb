require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'

#CONSTANTS
page_size = 100
lastdonationid = ""
more = 0
total = 0
logfile_prefix = "donations"
totcreated = 0
totupdated = 0
donupdatedcount = 0
prsupdatedcount = 0
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
LOGGER.info("=============================================================")
LOGGER.info("Updating Funds")
fnd = funds()
inner_loop_index = 0
fnd["data"].each do |u|
  fndcheck = Fund.where(:fund_id_pco => u["id"])
  if !fndcheck.exists?
      fundpost = Fund.create(
          :fund_id_pco              =>  u["id"],
          :name                     =>  u["attributes"]["name"],
          :description              =>  u["attributes"]["description"],
          :fund_updated_at          =>  u["attributes"]["updated_at"]
      )
      totcreated += 1
    elsif  !(fndcheck[0].fund_updated_at == u["attributes"]["updated_at"])
      fundpost = Fund.update(
          :fund_id_pco              =>  u["id"],
          :name                     =>  u["attributes"]["name"],
          :description              =>  u["attributes"]["description"],
          :fund_updated_at          =>  u["attributes"]["updated_at"]
      )
      else
      end
      inner_loop_index += 1
end

LOGGER.info("** All funds processed  **")
LOGGER.info("Total funds created: #{totcreated}")

totcreated = 0
totupdated = 0

LOGGER.info("=============================================================")
LOGGER.info("Processing Donations")

while !next_check.nil?
  don = get_donations(page_size,offset_index)
  next_check = don["links"]["next"]
  donations_data = don["data"]
  donations_data.each do |dd|
    donation_id         =   dd['id']
    !dd['relationships']['person']['data'].nil? ? pco_id  = dd['relationships']['person']['data']['id'] : pco_id = "000000"
    amount              =   dd['attributes']['amount_cents']/100
    donation_created_at =   dd['attributes']['created_at']
    donation_updated_at =   dd['attributes']['updated_at']
    payment_channel     =   dd['attributes']['payment_channel']
    payment_method      =   dd['attributes']['payment_method']
    payment_method_sub  =   dd['attributes']['payment_method_sub']
    designations(donation_id)["data"].each do |des|
            des_id = des["id"]
            des_amount = des["attributes"]["amount_cents"]/100
            fund_id_pco = des["relationships"]["fund"]["data"]["id"]
            fund_id = Fund.where(:fund_id_pco => fund_id_pco)[0].id
            designationscheck = Donation.where(:designation_id => des_id)

            if !designationscheck.exists?
              ## then do all this to create new record
              LOGGER.info("Creating new record for Donation ID #{donation_id} #{des_id} #{pco_id} Offset: #{offset_index} ")
              # stuff the people array with required field data

              donationnew = Donation.create(
              :donation_id            =>  donation_id,
              :amount                 =>  des_amount,
              :donation_created_at    =>  donation_created_at,
              :donation_updated_at    =>  donation_updated_at,
              :payment_channel        =>  payment_channel,
              :payment_method         =>  payment_method,
              :payment_method_sub     =>  payment_method_sub,
              :designation_id         =>  des_id,
              :designation            =>  des_amount,
              :fund_id_pco            =>  fund_id_pco,
              :fund_id                =>  fund_id,
              :pco_id                 =>  pco_id
              )

              totcreated += 1
                # pco_id not in db, so use create
            elsif  !(designationscheck[0].donation_updated_at == donation_updated_at)

              LOGGER.info("Updating new record for Donation ID #{donation_id} #{des_id} #{pco_id} Offset: #{offset_index} ")
              donationexist = Donation.update(designationscheck[0].id,
              :donation_id            =>  donation_id,
              :amount                 =>  des_amount,
              :donation_created_at    =>  donation_created_at,
              :donation_updated_at    =>  donation_updated_at,
              :payment_channel        =>  payment_channel,
              :payment_method         =>  payment_method,
              :payment_method_sub     =>  payment_method_sub,
              :designation_id         =>  des_id,
              :designation            =>  des_amount,
              :fund_id_pco            =>  fund_id_pco,
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

# #Update all Donation for association
LOGGER.info("=============================================================")
LOGGER.info("Updating :fund associations ...")
#CheckIn.where(:person_id => nil).each do |chk|
Donation.all.each do |don|
     f = Fund.where(:fund_id_pco => don.fund_id_pco)
     if f.count > 0 # matching fund_ids
        don.update(:fund_id => f[0].id)
        donupdatedcount += 1
     end
end
LOGGER.info("Updating Campaign associations ...")
Campaign.all.each do |camp|
     f = Fund.where(:fund_id_pco => camp.fund_id_pco)
     if f.count > 0 # matching fund_ids
        camp.update(:fund_id => f[0].id)
     end
end


#open_log.close
LOGGER.info("=============================================================")
LOGGER.info("Updating :person_id associations from Person dB...")
Donation.all.each do |don|
     p = Person.where(:pco_id => don.pco_id)
     if p.count > 0 # matching pco_ids
        don.update(:person_id => p[0].id)
        prsupdatedcount += 1
     end
end
LOGGER.info("=============================================================")
LOGGER.info("** All records processed **")
LOGGER.info("Donation Associations updated: #{donupdatedcount}")
LOGGER.info("People Associations updated: #{prsupdatedcount}")
LOGGER.info("Total Donation records created: #{totcreated}")

# #Run Weekly Household Giving report

dow = Date.today.strftime("%A")
#if dow == "Sunday"
if dow == "Tuesday"
  LOGGER.info("=============================================================")
  LOGGER.info("Beginning Household Giving report...")
  household_giving_report()
  LOGGER.info("Household Giving report updated to database")

end

LOGGER.info("=============================================================")
LOGGER.info("Script ended at #{datestamp}")
LOGGER.info("=============================================================")
LOGGER.info("SCRIPT COMPLETED SUCCESSFULLY")
if !File.readlines(logfile).grep(/SCRIPT COMPLETED SUCCESSFULLY/).any?
  LOGGER.info("Script execution failed!")
  eml_body = File.read(logfile)
  LOGGER.info("Emailing log file to #{eml_address}")
  PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
end
