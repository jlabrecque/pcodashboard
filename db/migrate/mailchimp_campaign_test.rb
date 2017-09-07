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
# Mailchimp credentials to be stored in file called
# <approot>/private/mc_credentials.
# To protect this key, it is critical that
# the <approot>/private directory be added to
#the .gitignore file so that it does not get
# posted publically

#set primary PCO Mailchimp list ID

@targetlist = 'cee04042fa'
campaignid = '106ebb5e77'
targetemail = Digest::MD5.hexdigest("dave@community-christian.us")
$mc_total_members = 0
page_size = 25
offset_index = 0
email_array = []

    @campaigns = get_mc_campaign(campaignid,page_size,offset_index)
#@campaigns = get_mc_campaign_emails(campaignid,page_size,offset_index)
pp @campaigns

# campaign total list pull
#@campaigns["campaigns"].each do |c|
#    pp c
#end
#initial load of total

# per campaign emails  pull
#@campaigns["sent_to"].each do |c|
#    pp c
#end
#initial load of total

#if mc_total = 0
#  mc_total = mailchimp["total_items"]
#end
#    puts mc_total
#gopen = gibbon.lists(targetlist).members(targetemail).retrieve
#pp gopen
