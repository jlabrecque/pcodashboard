require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'calendar_methods.rb'

qx = "q2"
year = "2017"


Campaign.where(:closed => 0).each do |campaign|
    totalprogress = 0.00
    totalpledge = 0.00
    num_donations = 0
    num_pledges = 0
    cid = campaign
    cname = campaign.campaign_name
    fund = campaign.fund_id_pco
    Donation.where(:fund_id_pco => campaign.fund_id_pco).each do |don|
      totalprogress += don.amount_cents/100
      num_donations += 1
    end
    campaign.update_attributes(:totalprogress => totalprogress, :num_donations => num_donations)

@calendar,lastsunday = get_calendar()
qstart,qend = quarter_pins(@calendar,qx,year)

#Per pledge
Pledge.all.where(:campaign => campaign.campaign_id).each do |pledge|
      pperiod = pledge.pledge_perperiod
      numperiods = pledge.pledge_periods
      periodicity = pledge.periodicity
      # pledge_perperiod: 0, pledge_periods: 0, periodicity: "none", pledge_start: "1/1/2017",
      # NEED to test when pledge_start -> pledge_periods is over!!
      num_pledges += 1
      total = 0
      ptotal = 0
      #per person calendar
      @calendar,lastsunday = get_calendar()
    # first stuff calendar for primary pco_id
      pledge_donations(pledge.pco_id,campaign.fund_id_pco,@calendar)
    # then, if a secondary pco_id exists (spouse)...
      if !pledge.pco_id2.nil?
        pledge_donations(pledge.pco_id2,campaign.fund_id_pco,@calendar)
      end
      dtotal,ptotal,ctotal,progress,display_calendar = quarter_totals(@calendar,qstart,qend,pledge.pledge_start,pledge.initial_gift,"l")
      ppercent,pproject,cpercent,cproject = pledge_calcs(ptotal,ctotal,pledge.initial_gift,pperiod,numperiods,periodicity,progress)
      # Sum each pledgers campaign projected total
      totalpledge += (pledge.pledge_periods * pledge.pledge_perperiod)
      #
 end
 puts num_pledges
 num_pledges > 0 ? avgpledge = totalpledge / num_pledges : avgpledge = 0
 totalpledge > 0 ? percentprogress = totalprogress / totalpledge : percentprogress = 0.0
 puts "CampaignName: #{campaign.campaign_name} Start Date:#{campaign.start_date}  TotalPledged:#{totalpledge} TotalProgress: #{totalprogress} #Pledges:#{num_pledges}  AveragePledge:#{avgpledge}  %Progress:#{percentprogress} "

 campaign.update_attributes(:num_pledges => num_pledges, :totalcommitted => totalpledge)
 cmupdate = CampaignMetum.create(
            :campaign_id        =>    campaign.campaign_id,
            :campaign_name      =>    campaign.campaign_name,
            :totalpledged       =>    totalpledge,
            :totalprogress      =>    totalprogress,
            :percentprogress    =>    percentprogress,
            :num_pledges        =>    num_pledges
 )
end
