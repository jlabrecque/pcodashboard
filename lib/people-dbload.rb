require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'
require 'dotenv'
require 'dotenv-rails'
#CONSTANTS
page_size = 50
high_pco_count = 0
totmembers = 0
totprocessed = 0
totcreated = 0
totupdated = 0
next_check = 0
$pullcount = 0
datestamp = Time.now
set_endtime()
logfile_prefix = "people"
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('People_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1 and ARGV.first == "update"
        LOGGER.info("Performing full update, checking all records for updates")
        offset_index = 0
  else
        prepeoplemeta = Metum.people.last
        !prepeoplemeta.nil? ? offset_index = prepeoplemeta.last_offset : offset_index = 0
        LOGGER.info("Performing delta update, based on last offset completed: #{offset_index}")
  end

#Start ...
LOGGER.info("=============================================================")
LOGGER.info("people_dbload.rb is a Ruby script to load the current ")
LOGGER.info("Planning Center People data within the churches account")
LOGGER.info("using the PCO API. The script checks the API collected data ")
LOGGER.info("against the current local database data, creates new records")
LOGGER.info("when they dont exist, update if record has been updated since")
LOGGER.info("the last API pull, and skips duplicates")
LOGGER.info(" ")
LOGGER.info("The script also creates a summary records under")
LOGGER.info("PeopleMeta recording the total created, updated and date")
LOGGER.info(" ")
LOGGER.info("Planning Center rate limits API pulls to 100 per minute, so")
LOGGER.info("the script also counts the API pulls against a 1 minute")
LOGGER.info("counter, and if approach the rate limit, will sleep the")
LOGGER.info("script to keep within the limit")
LOGGER.info("=============================================================")

#OUTER LOOP - per page size (ie 25, 50 records)
#if next exists (not at end)...
  while !next_check.nil?
    # pull groups of records
    ppl = people(page_size,offset_index)
    next_check = ppl["links"]["next"]
    last_offset_index = offset_index
    offset_index += page_size
    # per person loop
    ppl["data"].each do |u|
    pco_id = u["id"]
      prs = person(pco_id)
      camp = find_person_campus(pco_id)
      fname = u["attributes"]["first_name"]
      lname = u["attributes"]["last_name"]
      fullname = "#{fname} #{lname}"
      personcheck = Person.where(:pco_id => pco_id)
        # Populate variables
        email = JSON.parse(prs["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0].nil? ? "" : JSON.parse(prs["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["address"]
        ## Check if phone is nil, and if so, set to "". If not, grab mobile and home info
        phone = JSON.parse(prs["included"].select {|k| k["type"] == "PhoneNumber"}.to_json)
        if !phone.select {|m| m["attributes"]["location"] == "Mobile"}.empty?
          @mphone_carrier = phone[0]["attributes"]["carrier"]
          @mphone_number = phone[0]["attributes"]["number"]
        else
          @mphone_carrier = ""
          @mphone_number = ""
        end
        if !phone.select {|m| m["attributes"]["location"] == "Home"}.empty?
          @hphone = phone[0]["attributes"]["number"]
        else
          @hphone = ""
        end
        ## Check if address is nil, and if so, set to "".
        if JSON.parse(prs["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0].nil?
            street = ""
            city = ""
            state = ""
            zip = ""
        else
            street = JSON.parse(prs["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["street"]
            city = JSON.parse(prs["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["city"]
            state = JSON.parse(prs["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["state"]
            zip = JSON.parse(prs["included"].select {|k| k["type"] == "Address"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["zip"]
          end
          peopleapp_link = "https://people.planningcenteronline.com/people/AC"+prs["data"]["id"]
          membership = prs["data"]["attributes"]["membership"]
        totmembers = (membership == "Member") ? totmembers +=1 : totmembers
## If exists
      if !personcheck.exists?
        # pco_id not in db, so use create
        LOGGER.info("Creating new record for #{fname} #{lname} Offset: #{last_offset_index}")
        # stuff the people array with required field data
        personnew = Person.create(
        :pco_id            => pco_id,
        :first_name        => fname,
        :last_name         => lname,
        :middle_name       => prs["data"]["attributes"]["middle_name"],
        :nickname          => prs["data"]["attributes"]["nickname"],
        :fullname          => fullname,
        :email             => email,
        :hphone            => @hphone,
        :mphone            => @mphone_number,
        :carrier           => @mphone_carrier,
        :gender            => prs["data"]["attributes"]["gender"],
        :birthdate         => prs["data"]["attributes"]["birthdate"],
        :membership        => membership,
        :street            => street,
        :city              => city,
        :state             => state,
        :zip               => zip,
        :campus            => camp,
        :peopleapp_link    => peopleapp_link,
        :people_thumbnail  => prs["data"]["attributes"]["avatar"],
        :people_status     => prs["data"]["attributes"]["status"],
        :pco_created_at  => prs["data"]["attributes"]["created_at"],
        :pco_updated_at  => prs["data"]["attributes"]["updated_at"]
        )
        totcreated += 1
      elsif    !(personcheck[0].pco_updated_at == prs["data"]["attributes"]["updated_at"])
        # exists, but not uptodate
          LOGGER.info("Updating record for #{fname} #{lname}  Offset: #{last_offset_index}")
      # stuff the people array with required field data
          personup = Person.update(personcheck[0].id,
          :pco_id            => pco_id,
          :first_name        => fname,
          :last_name         => lname,
          :middle_name       => prs["data"]["attributes"]["middle_name"],
          :nickname          => prs["data"]["attributes"]["nickname"],
          :fullname          => fullname,
          :email             => email,
          :hphone            => @hphone,
          :mphone            => @mphone_number,
          :carrier           => @mphone_carrier,
          :gender            => prs["data"]["attributes"]["gender"],
          :birthdate         => prs["data"]["attributes"]["birthdate"],
          :membership        => membership,
          :street            => street,
          :city              => city,
          :state             => state,
          :zip               => zip,
          :campus            => camp,
          :peopleapp_link    => peopleapp_link,
          :people_thumbnail  => prs["data"]["attributes"]["avatar"],
          :people_status     => prs["data"]["attributes"]["status"],
          :pco_created_at  => prs["data"]["attributes"]["created_at"],
          :pco_updated_at  => prs["data"]["attributes"]["updated_at"]
          )
          totupdated += 1
      else
          LOGGER.info("** No action for #{fname} #{lname}  Offset: #{last_offset_index} **")
      end
      high_pco_count = prs["data"]["id"]
      totprocessed += 1
  end
end
LOGGER.info("Total processed: #{totprocessed}")
LOGGER.info("Total members: #{totmembers}")
LOGGER.info("Total created: #{totcreated}")
LOGGER.info("Total updated: #{totupdated}")
LOGGER.info("Last Offset Processed:  #{last_offset_index}")
LOGGER.info("Last PCO ID Processed: #{high_pco_count}")
#Write peoplemeta record
peoplemeta = Metum.create(
    :modeltype => "people",
    :last_offset => last_offset_index,
    :last_id_imported => high_pco_count,
    :total_processed => totprocessed,
    :total_created => totcreated,
    :total_updated => totupdated)
eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
