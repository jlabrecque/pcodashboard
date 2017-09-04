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


@targetlist = 'cee04042fa'
$mc_total_members = 0
page_size = 25
offset_index = 0
total_created = 0
total_updated = 0
total_skipped = 0
item_count = 0

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
      puts "Creating record for: #{m["email_address"]}"
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
        puts "Updating record for: #{m["email_address"]}"
end
=begin
      else
          total_skipped += 1
          puts "** No action for #{m["email_address"]} **"
      end
=end
      item_count += 1
    end
    offset_index += page_size
end
puts "Total created: #{total_created}"
puts "Total updated: #{total_updated}"
puts "Total skipped: #{total_skipped}"
