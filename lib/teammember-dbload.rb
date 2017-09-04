require 'rubygems'
require 'json'
require 'pp'
require 'date'
require 'pcocore_api.rb'


#set inner and outer indexes to 0
offset_index = 0
page_size = 25
$pullcount = 0
$endtime = Time.now + 60
planwindow = Date.today - 90
next_check = 0
tot_created = 0
tot_updated = 0
tot_skipped = 0
datestamp = Time.now
set_endtime()
logfile_prefix = "Teammember"
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('Teammember_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

#Start ...
LOGGER.info("=============================================================")
LOGGER.info("teammember_dbload.rb is a Ruby script to load the current ")
LOGGER.info("Planning Center Services team assignment data within ")
LOGGER.info("the churches account using the PCO API. The script checks ")
LOGGER.info("the API collected data against the current local database data,")
LOGGER.info("creates new records when they dont exist, update if record has")
LOGGER.info("been updated since the last API pull, and skips duplicates")
LOGGER.info(" ")
LOGGER.info("Planning Center rate limits API pulls to 100 per minute, so")
LOGGER.info("the script also counts the API pulls against a 1 minute")
LOGGER.info("counter, and if approach the rate limit, will sleep the")
LOGGER.info("script to keep within the limit")
LOGGER.info("=============================================================")

LOGGER.info("Starting processing...")
ServiceType.all.each do |st|
    Plan.where(:stid => st["stid"]).each do |pl|
      if pl["pl_updated_at"].to_date.strftime("%Y-%m-%d") < planwindow.to_s
        LOGGER.info("Plan update before update window -- skipping")
      else
        while !next_check.nil?
            tm = team_members(st["stid"],pl["plid"],page_size,offset_index)
            next_check = tm["links"]["next"]
                tm["data"].each do |member|

                      pco_id        =   member["relationships"]["person"]["data"]["id"]
                      tmid          =   member["id"]
                      tmname        =   member["attributes"]["name"]
                      tmstatus      =   member["attributes"]["status"]
                      tmreason      =   member["attributes"]["decline_reason"]
                      !tmreason.nil?  ? tmreason = tmreason.tr('^A-Za-z0-9 ', '') : tmreason = ""
                      tmposition    =   member["attributes"]["team_position_name"]
                      pldates       =   pl["pldates"]
                      pl_sort_date  =   pl["pl_sort_date"]
                      membercheck   = Teammember.where(:tmid => tmid)
                      person        = Person.where(:pco_id => pco_id)
                      if !membercheck.exists?
                        ## then do all this to create new record
                      LOGGER.info("Creating new record for TeamMember ID #{tmid}")

                        newmember = Teammember.create(
                            :plan_id            =>   pl["id"],
                            :person_id          =>   person[0]["id"],
                            :plid               =>   pl["plid"],
                            :plan_dates         =>   pldates,
                            :plan_sort_date     =>   pl_sort_date,
                            :tmid               =>   tmid,
                            :pco_id             =>   pco_id,
                            :name               =>   tmname,
                            :position           =>   tmposition,
                            :status             =>   tmstatus,
                            :decline_reason     =>   tmreason,
                            :plan_updated_at    =>   member["attributes"]["updated_at"]
                        )
                        tot_created += 1
                          # pco_id not in db, so use create
                      elsif  !(membercheck[0].plan_updated_at == member["attributes"]["updated_at"])
                        LOGGER.info("Updating existing record for TeamMember ID #{tmid}")
                        upmember = Teammember.update(membercheck[0].id,
                        :plan_id            =>   pl["id"],
                        :person_id          =>   person[0]["id"],
                        :plid               =>   pl["plid"],
                        :plan_dates         =>   pldates,
                        :plan_sort_date     =>   pl_sort_date,
                        :tmid               =>   tmid,
                        :pco_id             =>   pco_id,
                        :name               =>   tmname,
                        :position           =>   tmposition,
                        :status             =>   tmstatus,
                        :decline_reason     =>   tmreason,
                        :plan_updated_at    =>   member["attributes"]["updated_at"]
                        )

                        tot_updated += 1
                      else
                        LOGGER.info("No action for TeamMember ID #{tmid}")
                        tot_skipped += 1
                      end
                end
            offset_index += page_size
        end
        next_check = 0
        offset_index = 0
      end
    end
end
# puts "** ALl records processed -- CSV file complete **"
LOGGER.info("Total Created: #{tot_created}")
LOGGER.info("Total Updated: #{tot_updated}")
LOGGER.info("Total Skipped: #{tot_skipped}")
