require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'mailchimp'
#require 'gibbon'
require 'dotenv'
require 'dotenv-rails'
require 'digest/md5'
require 'mailchimp_api.rb'
require 'pcocore_api.rb'

page_size = 200
offset_index = 0
total_created = 0
total_updated = 0
total_items = 1
total_skipped = 0
item_count = 0
logfile_prefix = "mailchimp"
datestamp = Time.now
set_endtime()
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"

LOGGER = Log4r::Logger.new('Mailchimp_dbload.log')
LOGGER.outputters << Log4r::StdoutOutputter.new('stdout')
LOGGER.outputters << Log4r::FileOutputter.new('file', :filename => logfile)
#Start ...
LOGGER.info("=============================================================")
LOGGER.info("mailchimp-dbload.rb is a Ruby script to load the current ")
LOGGER.info("PCO related Mailchimp data within the churches MC account.")
LOGGER.info("This script updates:")
LOGGER.info(" - mailchimp list members against PCO people emails")
LOGGER.info(" - mailchimp campaign data")
LOGGER.info(" - mailchimp campaign send data")
LOGGER.info("=============================================================")
## Load Mailchimp Campaign Data

LOGGER.info("Starting MC Campaign updates...")

while item_count < total_items
      @campaigns = get_mc_campaigns(page_size,offset_index)
      total_items = @campaigns["total_items"]
      # campaign total list pull
      @campaigns["campaigns"].each do |c|
          if c["status"] == "sent" # only push sent campaigns to the dB
                campaignexists = Mccampaign.where(:mailchimp_campaign_id => c["id"])

                    if campaignexists.count == 0
                        Mccampaign.create(
                        :mailchimp_campaign_id          =>    c["id"],
                        :web_id                         =>    c["web_id"],
                        :campaign_type                           =>    c["type"],
                        :create_time                    =>    c["create_time"],
                        :send_time                      =>    c["send_time"],
                        :long_archive_url               =>    c["long_archive_url"],
                        :status                         =>    c["status"],
                        :emails_sent                    =>    c["emails_sent"],
                        :subject_line                   =>    c["settings"]["subject_line"],
                        :title                          =>    c["settings"]["title"],
                        :from                           =>    c["settings"]["from"],
                        :reply_to                       =>    c["settings"]["reply_to"],
                        :opens                          =>    c["report_summary"]["opens"],
                        :unique_opens                   =>    c["report_summary"]["unique_opens"],
                        :open_rate                      =>    c["report_summary"]["open_rate"],
                        :clicks                         =>    c["report_summary"]["clicks"],
                        :click_rate                     =>    c["report_summary"]["subscriber_clicks"],
                        :subscriber_clicks              =>    c["report_summary"]["click_rate"]
                        )
                        total_created += 1
                      else

                        Mccampaign.update(campaignexists[0]["id"],
                        :web_id                         =>    c["web_id"],
                        :campaign_type                  =>    c["type"],
                        :create_time                    =>    c["create_time"],
                        :send_time                      =>    c["send_time"],
                        :long_archive_url               =>    c["long_archive_url"],
                        :status                         =>    c["status"],
                        :emails_sent                    =>    c["emails_sent"],
                        :subject_line                   =>    c["settings"]["subject_line"],
                        :title                          =>    c["settings"]["title"],
                        :from                           =>    c["settings"]["from"],
                        :reply_to                       =>    c["settings"]["reply_to"],
                        :opens                          =>    c["report_summary"]["opens"],
                        :unique_opens                   =>    c["report_summary"]["unique_opens"],
                        :open_rate                      =>    c["report_summary"]["open_rate"],
                        :clicks                         =>    c["report_summary"]["clicks"],
                        :click_rate                     =>    c["report_summary"]["subscriber_clicks"],
                        :subscriber_clicks              =>    c["report_summary"]["click_rate"]
                        )
                        total_updated += 1
                      end
            else
              total_skipped += 1
            end
            item_count += 1
      end
      last_offset = offset_index
      offset_index += page_size
end

mcwindow = Mccampaign.bysend.last.send_time.to_date
meta = Metum.create(:modeltype => "mccampaigns", :last_import => mcwindow)

LOGGER.info("Total MC Campaigns created: #{total_created}")
LOGGER.info("Total MC Campaigns  updated: #{total_updated}")
LOGGER.info("Total MC Campaigns  skipped: #{total_skipped}")
LOGGER.info("=============================================================")

## Load Mailchimp List Data

$mc_total_members = 0
page_size = 25
offset_index = 0
total_created = 0
total_updated = 0
total_skipped = 0
item_count = 0
LOGGER.info("Starting MC list member updates...")

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1 and ARGV.first == "update"
        LOGGER.info("Performing full MClist update, checking all records for updates")
        offset_index = 0
  else
        premclistmeta = Metum.mclist.last
        !premclistmeta.nil? ? offset_index = premclistmeta.last_offset : offset_index = 0
        LOGGER.info("Performing delta MClist update, based on last offset completed: #{offset_index}")
  end

#Creating new tracking meta
meta = Metum.create(:modeltype => "mclists",
:total_created => 0,
:last_id_imported => 0,
:last_offset => offset_index)

LOGGER.info("=============================================================")
LOGGER.info("Starting MC list member updates...")


while offset_index <= $mc_total_members
    @members = get_mc_members(page_size,offset_index)

    @members["members"].each do |m|
      # person is an array of PCO people records matching the emai address
      # structured as an array, as one email may be used by many/family
      person_id = find_person_email(m["email_address"])
      mccheck = Mailchimplist.where(:email_address => m["email_address"])
      mc_open = number_to_n_significant_digits((m["stats"]["avg_open_rate"]*100), n = 3)
      mc_click = number_to_n_significant_digits((m["stats"]["avg_click_rate"]*100), n = 3)

      if !mccheck.exists?
        mcrecord = Mailchimplist.create(
            :email_address    =>    m["email_address"],
            :person_id        =>    person_id,
            :lname            =>    m["merge_fields"]["FNAME"],
            :fname            =>    m["merge_fields"]["LNAME"],
            :open_rate        =>    mc_open,
            :click_rate       =>    mc_click,
            :status           =>    m["status"],
            :email_client     =>    m["email_client"],
            :timezone         =>    m["location"]["timezone"],
            :country          =>    m["location"]["country_code"],
            :longitude        =>    m["location"]["longitude"],
            :latitude         =>    m["location"]["latitude"],
            :info_changed     =>    m["last_changed"],
            :email_type       =>    m["email_type"],
            :unique_id        =>    m["unique_id"],
            :list_id          =>    m["list_id"]
        )
        total_created += 1
    else # !(mccheck[0]["info_changed"] == m["last_changed"])
        mcrecord = Mailchimplist.update(mccheck[0].id,
            :email_address    =>    m["email_address"],
            :person_id        =>    person_id,
            :lname            =>    m["merge_fields"]["FNAME"],
            :fname            =>    m["merge_fields"]["LNAME"],
            :open_rate        =>    mc_open,
            :click_rate       =>    mc_click,
            :status           =>    m["status"],
            :email_client     =>    m["email_client"],
            :timezone         =>    m["location"]["timezone"],
            :country          =>    m["location"]["country_code"],
            :longitude        =>    m["location"]["longitude"],
            :latitude         =>    m["location"]["latitude"],
            :info_changed     =>    m["last_changed"],
            :email_type       =>    m["email_type"],
            :unique_id        =>    m["unique_id"],
            :list_id          =>    m["list_id"]
        )
        total_updated += 1
    end
      item_count += 1
    end
    last_offset_index = offset_index
    meta = Metum.update(meta.id,
    :total_created => total_created,
    :total_updated => total_updated,
    :total_processed => total_created + total_updated,
    :last_offset => last_offset_index)
    offset_index += page_size
end


LOGGER.info("Total MC List Members created: #{total_created}")
LOGGER.info("Total MC List Members updated: #{total_updated}")
LOGGER.info("Total MC List Members skipped: #{total_skipped}")
LOGGER.info("=============================================================")

## Load Mailchimp Campaign Send Data

page_size = 200
offset_index = 0
total_created = 0
total_updated = 0
total_items = 1
total_skipped = 0
item_count = 0
LOGGER.info("Starting MC campaign send updates...")

# if no MCcampaign records exist, do all. Else, update send records for Campaigns sent in the last 60 days
Mccampaign.count == 0 ? mcwindow = "Fri, 01 Jan 2010" : mcwindow = Mccampaign.bysend.last.send_time.to_date - 60
Mccampaign.where("create_time > ?",mcwindow).all.each do |c|
#Mccampaign.all.each do |c|

        mccampaign_id = c["id"]
        mailchimp_campaign_id = c["mailchimp_campaign_id"]
        @csends = get_mc_campaign_emails(mailchimp_campaign_id,page_size,offset_index)
        @csends["sent_to"].each do |s|
              person                = Person.where(:email => s["email_address"])
              person.empty?         ? person_id = 0 : person_id = person[0]["id"]
              mailchimp_email_id    = s["email_id"]
              email_address         = s["email_address"]
              mailchimp_list_id     = s["list_id"]
              first_name            = s["merge_fields"]["FNAME"]
              last_name             = s["merge_fields"]["LNAME"]
              status                = s["status"]
              open_count            = s["open_count"]
              open_count = 0 ? last_open = "" : last_open = s["last_open"]
          # mccampaignsendcheck = mailchimp_email_id + "+" + mailchimp_list_id + "+" + mailchimp_campaign_id
          mccampaignsendcheck = Mccampaignsend.where("mailchimp_email_id = ? and mailchimp_campaign_id = ? and mailchimp_list_id = ?",mailchimp_email_id,mailchimp_campaign_id,mailchimp_list_id)
          if mccampaignsendcheck.count == 0 # No records exist
                newsend = Mccampaignsend.create(
                :person_id                => person_id,
                :mccampaign_id            => mccampaign_id,
                :mailchimp_email_id       => mailchimp_email_id,
                :mailchimp_campaign_id    => mailchimp_campaign_id,
                :mailchimp_list_id        => mailchimp_list_id,
                :email_address            => email_address,
                :first_name               => first_name,
                :last_name                => last_name,
                :status                   => status,
                :open_count               => open_count,
                :last_open                => last_open
                )
                total_created += 1
          else
                newsend = Mccampaignsend.update(mccampaignsendcheck[0].id,
                :person_id                => person_id,
                :mccampaign_id            => mccampaign_id,
                :mailchimp_email_id       => mailchimp_email_id,
                :mailchimp_campaign_id    => mailchimp_campaign_id,
                :mailchimp_list_id        => mailchimp_list_id,
                :email_address            => email_address,
                :first_name               => first_name,
                :last_name                => last_name,
                :status                   => status,
                :open_count               => open_count,
                :last_open                => last_open
            )
            total_updated += 1
        end
    end
end

LOGGER.info("Total MC Send Records created: #{total_created}")
LOGGER.info("Total MC Send Records updated: #{total_updated}")
LOGGER.info("=============================================================")
LOGGER.info("All Mailchimp updates complete!")

eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
