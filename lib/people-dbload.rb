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
last_offset_index = 0
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

LOGGER.info("Adding/Updating Campus records...")
if !campus_fd().empty? #Multicampus configured Field Def
      field_options = campus_load()
      field_options["data"].each do |fo|
      campusexists = Campu.where(:campus_id_pco => fo["id"] )
        if campusexists.empty? #create
            LOGGER.info("Creating Campus: #{fo["attributes"]["value"]}")
            Campu.create(
            :campus_id_pco    =>  fo["id"],
            :campus_name  =>  fo["attributes"]["value"]
            )
            totcreated += 1
        else #update
            LOGGER.info("Updating Campus: #{fo["attributes"]["value"]}")
            Campu.update(campusexists[0]["id"],
            :campus_id_pco    =>  fo["id"],
            :campus_name  =>  fo["attributes"]["value"]
            )
            totupdated += 1
        end
      end
      #remove default Main Campus
      xcampus = Campu.where(:campus_id_pco => "000000")
      if xcampus.count > 0
        LOGGER.info("Removing default campus")
        xcampus[0].delete
      end
end
LOGGER.info("Campuses Created: #{totcreated}")
LOGGER.info("Campuses Updated: #{totupdated}")
LOGGER.info("=============================================================")
LOGGER.info("Adding/Updating People records...")
totcreated = 0
totupdated = 0
#Creating new tracking meta
meta = Metum.create(:modeltype => "people",
:total_created => 0,
:last_id_imported => 0,
:last_offset => offset_index)

#if next exists (not at end)...
  while !next_check.nil?
    # pull groups of records
    ppl = people(page_size,offset_index)
    next_check = ppl["links"]["next"]
    # per person loop
    ppl["data"].each do |u|
    pco_id = u["id"]
      prs = person(pco_id)
      emlarray = []
      @campus_name,@campus_id = find_person_campus(pco_id)
      fname = u["attributes"]["first_name"]
      lname = u["attributes"]["last_name"]
      fullname = "#{fname} #{lname}"
      personcheck = Person.where(:pco_id => pco_id)
        # Populate variables
        email = JSON.parse(prs["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0].nil? ? "" : JSON.parse(prs["included"].select {|k| k["type"] == "Email"}.to_json).select { |j| j["attributes"]["location"] == "Home"}[0]["attributes"]["address"]
        if !prs.nil?
            prs["included"].each do |data|
              if data["type"] == "Email"
                  emlentry = {"address" => data["attributes"]["address"], "location" => data["attributes"]["location"], "primary" => data["attributes"]["primary"]}
                  emlarray << emlentry
              end
            end
        end

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
        LOGGER.info("Creating new record for #{fname} #{lname} Offset: #{offset_index}")
        # stuff the people array with required field data
        personnew = Person.create(
        :pco_id            => pco_id,
        :first_name        => fname,
        :last_name         => lname,
        :middle_name       => prs["data"]["attributes"]["middle_name"],
        :nickname          => prs["data"]["attributes"]["nickname"],
        :fullname          => fullname,
        :email             => email,
        :email_array       => emlarray,
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
        :campus            => @campus_name,
        :campus_id         => @campus_id,
        :peopleapp_link    => peopleapp_link,
        :people_thumbnail  => prs["data"]["attributes"]["avatar"],
        :people_status     => prs["data"]["attributes"]["status"],
        :pco_created_at  => prs["data"]["attributes"]["created_at"],
        :pco_updated_at  => prs["data"]["attributes"]["updated_at"]
        )
        @pid = personnew.id
        totcreated += 1
      elsif    !(personcheck[0].pco_updated_at == prs["data"]["attributes"]["updated_at"])
        # exists, but not uptodate
          LOGGER.info("Updating record for #{fname} #{lname}  Offset: #{offset_index}")
      # stuff the people array with required field data
          personup = Person.update(personcheck[0].id,
          :pco_id            => pco_id,
          :first_name        => fname,
          :last_name         => lname,
          :middle_name       => prs["data"]["attributes"]["middle_name"],
          :nickname          => prs["data"]["attributes"]["nickname"],
          :fullname          => fullname,
          :email             => email,
          :email_array       => emlarray,
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
          :campus            => @campus_name,
          :campus_id         => @campus_id,
          :peopleapp_link    => peopleapp_link,
          :people_thumbnail  => prs["data"]["attributes"]["avatar"],
          :people_status     => prs["data"]["attributes"]["status"],
          :pco_created_at  => prs["data"]["attributes"]["created_at"],
          :pco_updated_at  => prs["data"]["attributes"]["updated_at"]
          )
          @pid = personcheck[0].id
          totupdated += 1
      else
          @pid = personcheck[0].id
      end
      # Grab all household records [array] associated with this person
      households = JSON.parse(prs["included"].select {|k| k["type"] == "Household"}.to_json)
      # Iterate through all households, add or update into Household records
      households.each do |h|
        housecheck = Household.where(:household_id_pco => h["id"])
        primary = Person.where(:pco_id => h["attributes"]["primary_contact_id"])[0]
        puts "Primary empty: #{Person.where(:pco_id => h["attributes"]["primary_contact_id"]).empty?} ID #{h["attributes"]["primary_contact_id"]}"
        puts "Primary nil: #{primary.nil?}"

        !if primary.nil?
            if !housecheck.exists?
              housenew = Household.create(
                :household_id_pco      =>    h["id"],
                :household_name        =>    h["attributes"]["name"],
                :household_primary_pco =>    primary.pco_id,
                :person_id             =>    primary.id,
                :campus_id             =>    primary.campus_id
              )
              hid = housenew.id
            else
              housenew = Household.update(housecheck[0]["id"],
                :household_id_pco  =>    h["id"],
                :household_name    =>    h["attributes"]["name"],
                :household_primary_pco =>    primary.pco_id,
                :person_id             =>    primary.id,
                :campus_id             =>    primary.campus_id
              )
              hid = housecheck[0]["id"]
            end
        end
        #### Create HouseholdPerson records
        hpcheck = HouseholdPerson.where(:household_id => hid,:person_id => @pid)
        if !hpcheck.exists?
          hpnew = HouseholdPerson.create(
            :household_id       =>      hid,
            :person_id          =>      @pid
          )
        else
          hpnew = HouseholdPerson.update(hpcheck[0].id,
            :household_id       =>      hid,
            :person_id          =>      @pid
          )
        end
      end

      high_pco_count = prs["data"]["id"]
      totprocessed += 1
  end
  last_offset_index = offset_index
  offset_index += page_size
  meta = Metum.update(meta.id,
  :total_created => totcreated,
  :total_updated => totupdated,
  :total_processed => totcreated + totupdated,
  :last_offset => last_offset_index)
end
LOGGER.info("=============================================================")
LOGGER.info("Updating donation associations...")
Person.all.each do |p|
  if !p.donations.empty?
    first_donation = p.donations.first.donation_created_at
    last_donation = p.donations.last.donation_created_at
    p.update(:first_donation => first_donation, :last_donation => last_donation)
  end
  if !p.check_ins.empty?
    first_checkin = p.check_ins.first.checkin_time
    last_checkin = p.check_ins.last.checkin_time
    p.update(:first_checkin => first_checkin, :last_checkin => last_checkin)
  end
  if !p.teammembers.empty?
    first_served = p.teammembers.first.plan_sort_date
    last_served = p.teammembers.last.plan_sort_date
    p.update(:first_served => first_served, :last_served => last_served)
  end
end
LOGGER.info("=============================================================")
LOGGER.info("Total People processed: #{totprocessed}")
LOGGER.info("Total Members: #{totmembers}")
LOGGER.info("Total People Created: #{totcreated}")
LOGGER.info("Total People Updated: #{totupdated}")
LOGGER.info("Last Offset Processed:  #{last_offset_index}")
LOGGER.info("Last PCO ID Processed: #{high_pco_count}")
LOGGER.info("=============================================================")

#CONSTANTS
offset_index = 0
page_size = 100
sleepval = 30
totprocessed = 0
totcreated = 0
totupdated = 0
$pullcount = 0
datestamp = Time.now
set_endtime()

# Getting List Info
LOGGER.info("Starting PCO List Processing...")

next_check = 0
while !next_check.nil?

    lists = lists(page_size,offset_index)
    next_check = lists["links"]["next"]

    lists["data"].each do |l|

        listcheck = Peoplelist.where(:list_id_pco => l["id"])

        if listcheck.count == 0 # No matching
            listrecord =  Peoplelist.create(
                :list_id_pco        =>  l["id"],
                :name               =>  l["attributes"]["name"],
                :description        =>  l["attributes"]["description"],
                :focallist          =>  FALSE,
                :status             =>  l["attributes"]["status"],
                :list_updated_pco   =>  l["attributes"]["updated_at"]
              )
            totcreated += 1
        elsif  !(listcheck[0].list_updated_pco == l["attributes"]["updated_at"])
            listrecord = Peoplelist.update(listcheck[0]["id"],
                :list_id_pco        =>  l["id"],
                :name               =>  l["attributes"]["name"],
                :description        =>  l["attributes"]["description"],
                :status             =>  l["attributes"]["status"],
                :list_updated_pco   =>  l["attributes"]["updated_at"]
            )
             totupdated += 1
        else
        end
 end
 offset_index += page_size
end
LOGGER.info("** ALl Lists processed  **")
LOGGER.info("Total Lists created: #{totcreated}")
LOGGER.info("Total Lists updated: #{totupdated}")
LOGGER.info("=============================================================")

# Getting Peoplelist_Person Info
LOGGER.info("Updating List Associations...")

totprocessed = 0
totcreated = 0
totupdated = 0
next_check = 0
offset_index = 0
page_size = 100

plp = PeoplelistPerson.count
plp = 0 ? updatewindow = "2010-01-01" : updatewindow = (Peoplelist.byupdate.last.list_updated_pco.to_date - 1.days).to_s
Peoplelist.where("list_updated_pco >= ?",updatewindow).all.each do |pl|
#Peoplelist.all.each do |pl|
#Peoplelist.all.each do |pl|
    lid_pco = pl.list_id_pco
    lid = pl.id
      while !next_check.nil?
          peoplelist = listpeople(pl.list_id_pco,page_size,offset_index)
          next_check = peoplelist["links"]["next"]
          peoplelist["data"].each do |p|
            person = Person.where(:pco_id => p["id"])[0]
            if person.nil?
              puts "Person #{p["id"][0]} is nil"
            else
                pid = person.id
                personcheck = PeoplelistPerson.where("peoplelist_id = ? and person_id = ?",lid,pid)
                  if personcheck.count == 0 # No matching
                      record =  PeoplelistPerson.create(
                          :peoplelist_id           =>  lid,
                          :person_id               =>  pid
                        )
                      totcreated += 1
                  else
                        record =  PeoplelistPerson.update(personcheck[0]["id"],
                            :peoplelist_id           =>  lid,
                            :person_id               =>  pid
                          )
                       totupdated += 1
                  end
            end
          end
          offset_index += page_size
      end
      next_check = 0
      offset_index = 0
end

LOGGER.info("** ALl PeopleListPeople processed  **")
LOGGER.info("Total PeopleListPeople created: #{totcreated}")
LOGGER.info("Total PeopleListPeople updated: #{totupdated}")
LOGGER.info("=============================================================")

####### Geocoding
LOGGER.info("Beginning DoW Geocode...")
people_geo_created = 0
people_geo_updated = 0
campus_geo_created = 0
campus_geo_updated = 0

#Add per person georecords
dow = Date.today.strftime("%A")

case dow
  when "Monday"
    regex = "^[a-dA-D]" # get last_names starting with A-F
  when "Tuesday"
    regex = "^[e-hE-H]" # get last_names starting with A-F
  when "Wednesday"
    regex = "^[i-lI-L]" # get last_names starting with A-F
  when "Thursday"
    regex = "^[m-pM-P]" # get last_names starting with A-F
  when "Friday"
    regex = "^[q-tQ-T]" # get last_names starting with A-F
  when "Saturday"
    regex = "^[u-wU-W]" # get last_names starting with A-F
  when "Sunday"
    regex = "^[x-zX-Z]" # get last_names starting with A-F
end
LOGGER.info("DoW is #{dow}, Pattern is #{regex}")

Person.where("last_name REGEXP ?", regex).each do |person|
  LOGGER.info("PCO_id: #{person.pco_id}, Name: #{person.last_name}, #{person.first_name}")
    address,long,lat = geocode_people(person.pco_id,person.street,person.city,person.state,person.zip)
    geoexists = GeoMap.where(:pco_id => person.pco_id)
    if !address.blank?
      if !geoexists.exists? #create new record

            georecord = GeoMap.create(
            :person_id      =>    person.id,
            :pco_id         =>    person.pco_id,
            :campus_id      =>    "na",
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          LOGGER.info("*** Creating new Georecord #{person.pco_id} #{address} ***")
          people_geo_created += 1
      else
            georecord = GeoMap.update(geoexists[0].id,
            :person_id      =>    person.id,
            :pco_id         =>    person.pco_id,
            :campus_id      =>    "na",
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          LOGGER.info("*** Updating Georecord  #{person.pco_id} #{address} ***")
          people_geo_updated += 1
      end
  end
end
#Add per Campus georecords
Campu.all.each do |campus|
    address,long,lat = geocode_people(campus.campus_id_pco,campus.street,campus.city,campus.state,campus.zip)
    geoexists = GeoMap.where(:campus_id => campus.campus_id_pco)
    if !address.blank?
      if !geoexists.exists? #create new record

            georecord = GeoMap.create(
            :person_id      =>    0,
            :pco_id         =>    "na",
            :campus_id      =>    campus.campus_id_pco,
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          campus_geo_created += 1
      else
            georecord = GeoMap.update(geoexists[0].id,
            :person_id      =>    0,
            :pco_id         =>    "na",
            :campus_id      =>    campus.campus_id_pco,
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          campus_geo_updated += 1
      end
  end
end
LOGGER.info("=============================================================")
LOGGER.info("All people and campus records processed")
LOGGER.info("")
LOGGER.info("#{people_geo_created} people geo records created")
LOGGER.info("#{campus_geo_created} campus geo records created")
LOGGER.info("=============================================================")

LOGGER.info("SCRIPT COMPLETED SUCCESSFULLY")
if !File.readlines(logfile).grep(/SCRIPT COMPLETED SUCCESSFULLY/).any?
  LOGGER.info("Script execution failed!")
  eml_body = File.read(logfile)
  LOGGER.info("Emailing log file to #{eml_address}")
  PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
end
