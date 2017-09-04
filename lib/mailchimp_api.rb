require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'gibbon'
require 'dotenv'
require 'dotenv-rails'
require 'digest/md5'
# Mailchimp credentials to be stored in file called
# <approot>/private/mc_credentials.
# To protect this key, it is critical that
# the <approot>/private directory be added to
#the .gitignore file so that it does not get
# posted publically

@settings = Setting.x

@targetlist = @settings.mailchimp_list

def get_mc_members(page_size,offset_index)

    gibbon = Gibbon::Request.new(api_key: @settings.mailchimpapikey)
    members_unp = gibbon.lists(@targetlist).members.retrieve(params: {"count": page_size, "offset": offset_index})
    @members = JSON.parse(members_unp.to_json)["body"]
    if $mc_total_members == 0
        $mc_total_members = @members["total_items"]
    end
    return @members
end

def number_to_n_significant_digits(number, n = 3)
   ("%f"%[("%.#{n}g"%number).to_f]).sub(/\.?0*\z/,'')
 end

def mc_email_lookup(targetemail)
 mc = Mailchimplist.where(:email_address => targetemail)
 if mc.empty?
     open_rate = 0.0
     click_rate = 0.0
 else
     open_rate = mc[0].open_rate
     click_rate = mc[0].click_rate
 end
 return open_rate,click_rate
end

def get_mc_campaigns(page_size,offset_index)

    gibbon = Gibbon::Request.new(api_key: @settings.mailchimpapikey)
    campaigns_unp = gibbon.campaigns.retrieve(params: {"count": page_size, "offset": offset_index})
    @campaigns = JSON.parse(campaigns_unp.to_json)["body"]

    return @campaigns
end

def get_mc_campaign(campaignid,page_size,offset_index)

    gibbon = Gibbon::Request.new(api_key: @settings.mailchimpapikey)
    campaigns_unp = gibbon.reports(campaignid).retrieve(params: {"count": page_size, "offset": offset_index})
    @campaign = JSON.parse(campaigns_unp.to_json)["body"]

    return @campaign
end

def get_mc_campaign_emails(campaignid,page_size,offset_index)

    gibbon = Gibbon::Request.new(api_key: @settings.mailchimpapikey)
    campaigns_unp = gibbon.reports(campaignid).sent_to.retrieve(params: {"count": page_size, "offset": offset_index})
    @campaign = JSON.parse(campaigns_unp.to_json)["body"]

    return @campaign
end
