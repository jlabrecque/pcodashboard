require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'

#CONSTANTS
offset_index = 0
plcount = 0
page_size = 50
totprocessed = 0
totcreated = 0
totupdated = 0
$pullcount = 0
logfile_prefix = "services"
datestamp = Time.now
set_endtime()
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('Services_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)

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


#Start ...
LOGGER.info("Starting ServiceTypes...")
st = service_type()
    inner_loop_index = 0
    st["data"].each do |u|

      stcheck = ServiceType.where(:stid => u["id"])

# If exists
        if !stcheck.exists?
            LOGGER.info("Creating new ST record")
            servicepost = ServiceType.create(
            :stid           =>  u["id"],
            :st_name        =>  u["attributes"]["name"],
            :st_updated_at  =>  u["attributes"]["updated_at"],
            :st_freq        =>  u["attributes"]["frequency"]
            )
            totcreated += 1


        elsif  !(stcheck[0].st_updated_at == st["data"][inner_loop_index]["attributes"]["updated_at"])
          LOGGER.info("Updated new ST record")

          servicepost = ServiceType.update(stcheck[0].id,
          :stid             =>  u["id"],
          :st_name          =>  u["attributes"]["name"],
          :st_updated_at    =>  u["attributes"]["updated_at"],
          :st_freq          =>  u["attributes"]["frequency"]
          )
        else
        end
            inner_loop_index += 1

    end
    LOGGER.info("** All records processed  **")
    LOGGER.info("Total ServiceTypes created: #{totcreated}")



totprocessed = 0
totcreated = 0
totupdated = 0
LOGGER.info("=================================================")
LOGGER.info("Starting process Plans...")
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
                        LOGGER.info("Creating new Plan record for ID #{stid} #{plid} #{pldates} #{pl_sort_date} #{pupdate}")
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
                        LOGGER.info("Updating existing Plan record for ID #{stid} #{plid} #{pldates} #{pl_sort_date} #{pupdate}")

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
                      end

                  end
            offset_index += page_size
        end
        offset_index = 0
        next_check = 0
end


plwindow = Plan.byupdate.last.pl_updated_at.to_date
meta = Metum.create(:modeltype => "plans", :last_import => plwindow)

LOGGER.info("** All Plans processed  **")
LOGGER.info("Total Plans created: #{totcreated}")
LOGGER.info("Total Plans updated: #{totupdated}")


checkwindow = (Plan.byupdate.last.pl_updated_at.to_date - 7.days).to_s #string
datestamp = Time.now #date
updatestamp = datestamp.strftime("%Y-%m-%d") #string
next_check = 0
totcreated = 0
totupdated = 0
totskipped = 0
set_endtime()

LOGGER.info("=================================================")
LOGGER.info("Starting processing Team members...")
ServiceType.all.each do |st|
     Plan.where("stid = ? and pl_updated_at >= ?",st["stid"],checkwindow).each do |pl|
        LOGGER.info("Processing ServiceType: #{st.stid} Plan: #{pl.plid}")
        while !next_check.nil?
            tm = team_members(st["stid"],pl["plid"],page_size,offset_index)
            if !tm.nil?
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
                              :planperson         =>   updatestamp,
                              :plan_updated_at    =>   member["attributes"]["updated_at"]
                          )
                          totcreated += 1
                            # pco_id not in db, so use create
                        elsif  !(membercheck[0].plan_updated_at == member["attributes"]["updated_at"])
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
                          :planperson         =>   updatestamp,
                          :plan_updated_at    =>   member["attributes"]["updated_at"]
                          )

                          totupdated += 1
                        else
                          upmember = Teammember.update(membercheck[0].id,
                          :planperson         =>   updatestamp
                          )
                          totskipped += 1
                        end
                  end
              offset_index += page_size
          else
            next_check = NIL
          end
        end
        next_check = 0
        offset_index = 0
    end
end
# puts "** ALl records processed -- CSV file complete **"
LOGGER.info("Total Teammembers Created: #{totcreated}")
LOGGER.info("Total Teammembers Updated: #{totupdated}")
LOGGER.info("Total Teammembers Skipped: #{totskipped}")
LOGGER.info("SCRIPT COMPLETED SUCCESSFULLY")
if !File.readlines(logfile).grep(/SCRIPT COMPLETED SUCCESSFULLY/).any?
  LOGGER.info("Script execution failed!")
  eml_body = File.read(logfile)
  LOGGER.info("Emailing log file to #{eml_address}")
  PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
end
