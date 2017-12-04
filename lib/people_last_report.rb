require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'date'

datestamp = Time.now
csvfilename = "People_Last_Report_#{datestamp.strftime ("%y%m%d%H%M")}.csv"
CSV.open("public/reports/#{csvfilename}", "w") do |csv|

    header = ["Last Name","First Name","Campus","Membership","Last Checkin","Last Served","Last Donation"]
    csv << header

    Person.member.active.each do |p|
      !p.last_checkin.nil? ? lastcheckin = p.last_checkin.to_date.strftime("%m/%d/%y") : lastcheckin = ""
      !p.last_served.nil? ? lastserved = p.last_served.to_date.strftime("%m/%d/%y") : lastserved = ""
      !p.last_donation.nil? ? lastdonation = p.last_donation.to_date.strftime("%m/%d/%y") : lastdonation = ""


      csv << [p.last_name,p.first_name,p.campus,p.membership,lastcheckin,lastserved,lastdonation]
    end

end
