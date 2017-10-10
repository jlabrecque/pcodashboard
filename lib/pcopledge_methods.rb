require 'rubygems'
require 'pp'
require 'date'
require "chartkick"
require 'google_visualr'
require 'csv'
require 'calendar_methods.rb'

#============================================
def dashboard_stack()
    stack_array = []
    Campaign.where(:closed => 0).each do |campaign|
        stack_array << {"name":"#{campaign.campaign_name} Pledged","data":{"Total":campaign.totalcommitted}}
        stack_array << {"name":"#{campaign.campaign_name} Progress","data":{"Total":campaign.totalprogress}}
    end
    return stack_array
end
#============================================

## need to flip so that dates are a series (line1) and data are a series (line2)

def dashboard_line()
    area_array = []
    CampaignMetum.all.each do |campaignmeta|
        area_array << {"name":"#{campaignmeta.campaign_name} Pledged","data":{"Total":campaignmeta.totalpledged,"date":campaignmeta.created_at}}
        area_array << {"name":"#{campaignmeta.campaign_name} Progress","data":{"Total":campaignmeta.totalprogress,"date":campaignmeta.created_at}}
    end
    return area_array
end

#============================================

# Create and Download pledge report 1

def download_csv(f)

send_file(
  "#{Rails.root}/public/#{f}",
  filename: "#{f}",
  type: "application/csv"
)
end
#============================================

def pledge_report(q,y,cpick)
    pledge_count = 0
    donation_count = 0
    $grand_total = 0
    $qgrand_total = 0
    lastsunday = 0
    datestamp = Time.now
    campaign = Campaign.all.where(:campaign_id => cpick)[0]
    # get quarter pins once
    @calendar,lastsunday = get_calendar()
    qstart,qend = quarter_pins(@calendar,q,y)
    csvfilename = "Pledge_Report_#{q}_#{y}_#{datestamp.strftime("%y%m%d%H%M")}.csv"
    CSV.open("public/reports/#{csvfilename}", "w") do |csv|

        # Create Header
          header = ["pco_id","Campaign","LastName","FirstName","Street","City","State","Zip","PledgeDate","InitialGift","PerPeriod","NumPledgePeriods","Periodicity","TotalQtrDonations","PeriodTotal","PeriodProject","PeriodPercent","CampaignTotal","CampaignProjected","CampaignPercent","Wk1","Wk2","Wk3","Wk4","Wk5","Wk6","Wk7","Wk8","Wk9","Wk10","Wk11","Wk12","Wk13"]
          puts header.join(',')
          csv << header
        #Per pledge
        Pledge.all.where(:campaign => campaign.campaign_id).each do |pledge|
          pperiod = pledge.pledge_perperiod
          numperiods = pledge.pledge_periods
          periodicity = pledge.periodicity
          # pledge_perperiod: 0, pledge_periods: 0, periodicity: "none", pledge_start: "1/1/2017",
          # NEED to test when pledge_start -> pledge_periods is over!!
          pledge_count += 1
          total = 0
          ptotal = 0
          street = ""
          city = ""
          state = ""
          zip = ""
            Person.all.where(:pco_id => pledge.pco_id).each do | person |
            #address = "#{person["street"]}"
                street = person.street
                city = person.city
                state = person.state
                zip = person.zip
            end
          street = street.gsub(/[\s,]/ ," ")

          #per person calendar
          @calendar,lastsunday = get_calendar()
        # first stuff calendar for primary pco_id
          pledge_donations(pledge.pco_id,campaign.fund_id_pco,@calendar)
        # then, if a secondary pco_id exists (spouse)...
            if !pledge.pco_id2.nil?
              pledge_donations(pledge.pco_id2,campaign.fund_id_pco,@calendar)
            end
          # get quarter pins
          # dtotal = total donations for this quarter
          # ptotal = compaign donations for this quarter
          # ctotal = total campaign donations from Campaign start
          dtotal,ptotal,ctotal,progress,display_calendar = quarter_totals(@calendar,qstart,qend,pledge.pledge_start,pledge.initial_gift,"l")
          pperent,pproject,cpercent,cproject = pledge_calcs(ptotal,ctotal,pledge.initial_gift,pperiod,numperiods,periodicity,progress)
          #display_calendar_string =
          pledgeline = [pledge.pco_id,campaign.campaign_name,pledge.lname,pledge.fname,street,city,state,zip,pledge.pledge_date,pledge.initial_gift,pledge.pledge_perperiod,pledge.pledge_periods,pledge.periodicity,dtotal,ptotal,pproject,pperent,ctotal,cproject,cpercent]
          pledgeline << display_calendar[display_calendar.count-13]
          pledgeline << display_calendar[display_calendar.count-12]
          pledgeline << display_calendar[display_calendar.count-11]
          pledgeline << display_calendar[display_calendar.count-10]
          pledgeline << display_calendar[display_calendar.count-9]
          pledgeline << display_calendar[display_calendar.count-8]
          pledgeline << display_calendar[display_calendar.count-7]
          pledgeline << display_calendar[display_calendar.count-6]
          pledgeline << display_calendar[display_calendar.count-5]
          pledgeline << display_calendar[display_calendar.count-4]
          pledgeline << display_calendar[display_calendar.count-3]
          pledgeline << display_calendar[display_calendar.count-2]
          pledgeline << display_calendar[display_calendar.count-1]
          puts pledgeline.join(',')
          csv << pledgeline
          #puts pledgeline
        end
    # => puts "Total Pledges: #{pledge_count}, total donations to Campaign: #{donation_count} total amount: #{$grand_total}"
    end
    return csvfilename
end

###############
