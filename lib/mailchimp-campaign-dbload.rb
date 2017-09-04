require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'mailchimp_api.rb'


campaigneol = FALSE
@targetlist = 'cee04042fa'
page_size = 200
offset_index = 0
total_created = 0
total_updated = 0
total_items = 1
total_skipped = 0
item_count = 0

while item_count < total_items
      @campaigns = get_mc_campaigns(page_size,offset_index)
      total_items = @campaigns["total_items"]
      # campaign total list pull
      @campaigns["campaigns"].each do |c|
          if c["status"] == "sent" # only push sent campaigns to the dB
                campaignexists = Mccampaign.where(:mailchimp_campaign_id => c["id"])

                    if campaignexists.count == 0
                        puts "Creating new Campaign entry for #{c["id"]}"
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
                      puts "Updating existing Campaign entry #{c["id"]}"

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
              puts "Campaign not sent -- skipping"
              total_skipped += 1
            end
            item_count += 1
      end
      offset_index += page_size
end
puts "Total created: #{total_created}"
puts "Total updated: #{total_updated}"
puts "Total skipped: #{total_skipped}"
