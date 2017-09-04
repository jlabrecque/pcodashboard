require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'
require 'log4r'

#CONSTANTS
offset_index = 0
page_size = 50
plcount = 0
logfile_prefix = "plans"
totprocessed = 0
totcreated = 0
totupdated = 0
$pullcount = 0
datestamp = Time.now
set_endtime()
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('Plans_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

#Start ...
puts "Starting processing..."

st = ServiceType.all

st.each do |s|
        stid = s["stid"]
        next_check = 0
        while !next_check.nil?
                  pl = plans(stid,page_size,offset_index)
                  next_check = pl["links"]["next"]
                  pl["data"].each do |p|
                      plid = p["id"]
                      plcount += 1
                      pldates = p["attributes"]["dates"]
                      pl_sort_date = p["attributes"]["sort_date"]
                      pupdate = p["attributes"]["updated_at"]
                      plancheck = Plan.where(:plid => plid)
                      #if the plans updated_at is less than the delta window, and the plan exists in DB skip the update
                      if !plancheck.exists?
                        LOGGER.info("Creating new record for Plan ID #{stid} #{plid} #{pldates} #{pl_sort_date} #{pupdate}")
                        plannew = Plan.create(
                            :plid               =>  plid,
                            :stid               =>  stid,
                            :pldates            =>  pldates,
                            :pl_sort_date       =>  pl_sort_date,
                            :pl_updated_at      =>  pupdate,
                            :service_type_id    =>  s["id"]
                        )
                        totcreated += 1
                      elsif  !(plancheck.first.pl_updated_at == pupdate)
                        LOGGER.info("Updating existing record for Plan ID #{stid} #{plid} #{pldates} #{pl_sort_date} #{pupdate}")

                        planexist = Plan.update(plancheck[0].id,
                            :plid               =>  plid,
                            :stid               =>  stid,
                            :pldates            =>  pldates,
                            :pl_sort_date       =>  pl_sort_date,
                            :pl_updated_at      =>  pupdate,
                            :service_type_id    =>  s["id"]
                        )
                        totupdated += 1
                      else
                        LOGGER.info("No action for Plan ID #{stid} #{plid} #{pldates} #{pl_sort_date} #{pupdate} ")
                      end

                  end
            offset_index += page_size
        end
        offset_index = 0
        next_check = 0
end


LOGGER.info("** All records processed  **")
LOGGER.info("Total created: #{totcreated}")
LOGGER.info("Total updated: #{totupdated}")
eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
