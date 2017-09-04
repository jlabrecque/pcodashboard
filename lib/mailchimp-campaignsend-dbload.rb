require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'mailchimp_api.rb'


page_size = 200
offset_index = 0
total_created = 0
total_updated = 0
total_items = 1
total_skipped = 0
item_count = 0

Mccampaign.all.each do |c|
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
          puts "Creating Campaign Send record..."
          newsend = Mccampaignsend.create(
          :person_id                =>  person_id,
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
        end
end

puts "Total created: #{total_created}"
