require 'rubygems'
require 'pp'
require 'date'

#============================================
def get_calendar()

    first_sunday = Date.parse('2016-01-03')
    today = (Date.today + 6)
    sunday_pointer = first_sunday
    index = 0

    calendar = {}
    while sunday_pointer <= today do
      sunday_pointer_t = sunday_pointer.strftime("%Y%m%d")
      lastsunday = sunday_pointer_t
      calendar[sunday_pointer_t] = {:date => sunday_pointer, :total => 0.00, :pledge => 0.00, :amount => 0.00, :group => "N", :attend => "N", :serve => "N", :index => index}
      sunday_pointer += 7
    end
    return calendar,lastsunday
end
#============================================
def checkin_grid(pid)
      calendar,lastsunday = get_calendar()
      stuff_checkins(pid,calendar)

      @checkincal = []
      calendar.each_key do |x|
        if calendar[x][:attend] == "V"
            xval = 2
        else
            xval = 1
        end
        newval =  [Date.parse(x), xval]
        @checkincal << newval
      end
      return @checkincal
end
#============================================
def donation_grid(pid)
      calendar,lastsunday = get_calendar()
      stuff_donations(pid,calendar)

      avgdonation = 0
      dontotal = 0
      doncount = 0
      @donationcal = []
      calendar.each_key do |x|
        donval = (calendar[x][:amount])
        if donval != 0
            tuple =  [Date.parse(x), donval]
            @donationcal << tuple
            doncount =+ 1
            dontotal =+ donval
        end
      end
      !doncount = 0 ? avgdonation = 0 : avgdonation = dontotal / doncount
      return @donationcal
end
#============================================
def serving_grid(pid)
      calendar,lastsunday = get_calendar()
      stuff_serving(pid,calendar)

      @servingcal = []
      calendar.each_key do |x|
        if calendar[x][:serve] == "Y"
            xval = 1
        else
            xval = 0
        end
        newval =  [Date.parse(x), xval]
        @servingcal << newval
      end
      return @servingcal
end
#============================================
def groups_grid(pid)
      calendar,lastsunday = get_calendar()
      stuff_groups(pid,calendar)

      @groupscal = []
      calendar.each_key do |x|
        if calendar[x][:group] == "Y"
            xval = 2
        else
            xval = 1
        end
        newval =  [Date.parse(x), xval]
        @groupscal << newval
      end
      return @groupscal
end
#============================================
def stuff_checkins(pid,calendar)
    checkins = CheckIn.where(:pco_id => pid)
    checkins.each do |check|
        pin = check[:checkin_time].to_date
        calendar.each_key do |week|
            this_week = calendar[week][:date]
            next_week = this_week + 7
            if pin <= next_week and pin > this_week
               next_week_str = next_week.strftime("%Y%m%d")
               if check[:checkin_kind] == "Volunteer"
                 calendar[next_week_str][:attend] = "V"
               else
                 calendar[next_week_str][:attend] = "R"
               end
            end
        end
    end
  return calendar
end
#============================================
def stuff_donations(pid,calendar)
    donations = Donation.where(:pco_id => pid)
    donations.each do |don|
        pin = don[:donation_created_at].to_date
                calendar.each_key do |week|
                  this_week = calendar[week][:date]
                  next_week = this_week + 7
                  if pin <= next_week and pin > this_week
                     next_week_str = next_week.strftime("%Y%m%d")
                     calendar[next_week_str][:amount] = don[:amount]
                  end
                end
    end
  return calendar
end

def stuff_tithe(pid,calendar)
    donations = Donation.where(:pco_id => pid).tithe
    donations.each do |don|
        pin = don[:donation_created_at].to_date
                calendar.each_key do |week|
                  this_week = calendar[week][:date]
                  next_week = this_week + 7
                  if pin <= next_week and pin > this_week
                     next_week_str = next_week.strftime("%Y%m%d")
                     calendar[next_week_str][:amount] = don[:amount]
                  end
                end
    end
  return calendar
end
#============================================
def stuff_donreport(pid,calendar)
    donations = Donation.where(:pco_id => pid)
    donations.each do |don|
        pin = don[:donation_created_at].to_date
                calendar.each_key do |week|
                  this_week = calendar[week][:date]
                  next_week = this_week + 7
                  if pin <= next_week and pin > this_week
                     next_week_str = next_week.strftime("%Y%m%d")
                     calendar[next_week_str][:amount] = don[:amount]
                  end
                end
    end
  return calendar
end
#============================================
def stuff_serving(pid,calendar)
    p = Person.where(:pco_id => pid)[0]
    serving = p.teammembers
    serving.each do |srv|
        pin = srv[:plan_sort_date].to_date
        calendar.each_key do |week|
          this_week = calendar[week][:date]
          next_week = this_week + 7
          if pin <= next_week and pin > this_week
            next_week_str = next_week.strftime("%Y%m%d")
            calendar[next_week_str][:serve] = "Y"
          end
        end
    end
  return calendar
end
#============================================
def stuff_groups(pid,calendar)
    p = Person.where(:pco_id => pid)[0]
    groupattendance = p.group_attendances
    groupattendance.each do |att|
        pin = att[:attend_date].to_date
        calendar.each_key do |week|
          this_week = calendar[week][:date]
          next_week = this_week + 7
          if pin <= next_week and pin > this_week
             next_week_str = next_week.strftime("%Y%m%d")
             calendar[next_week_str][:group] = "Y"
          end
        end
    end
  return calendar
end
#============================================
def pledge_donations(pid,fid,calendar)
  # used for PCOpledge report
    donations = Donation.where(:pco_id => pid)
    donations.each do |don|
        pin = don[:donation_created_at].to_date
          calendar.each_key do |week|
            this_week = calendar[week][:date]
            next_week = this_week + 7
              if pin <= next_week and pin > this_week
                 next_week_str = next_week.strftime("%Y%m%d")
                 # First add each don to :total
                 calendar[next_week_str][:total] += don[:amount]
                 #Then add the matching pledge fund $$ to the :pledge
                 if don[:fund_id_pco] == fid
                    calendar[next_week_str][:pledge] += don[:amount]
                 end

              end
          end
    end
  return calendar
end
#============================================
def quarter_totals(calendar,qstart,qend,cstart,initial_gift,mode)
  # used for PCOpledge report
  # mode switch used to dictate whether display_calendar output is
  # header ("h") for CSV output. Any other input is line mode
  ctotal = 0.00
  ptotal = 0.00
  dtotal = 0.00
  progress = 0

  display_calendar = []
  calendar.each do | week |

      # if between campaign start and quarter end, add to campaign total
      if week[0].to_date >= cstart.to_date and week[0].to_date <= qend.to_date
          ctotal += week[1][:pledge]
          progress += 1
          # also, if on or after quarter start, add to quarter total
          if week[0].to_date >= qstart.to_date
                dtotal += week[1][:total]
                ptotal += week[1][:pledge]
                case mode
                when "h"
                  display_calendar << week[0]
                else
                  display_calendar << (week[1][:pledge])
                end
          end
      else
      end
  end

  # add initial_gift to campaign total
  #initial_gift.nil? ? ctotal == 0 : ctotal += initial_gift
  return dtotal,ptotal,ctotal,progress,display_calendar

end
#============================================
def quarter_pins(calendar,qx,year)
  # used for PCOpledge report
  case qx
    when "Q1","q1"
      qstart = Date.parse("01-01-" + year).strftime("%Y%m%d")
      qend = Date.parse("31-03-" + year).strftime("%Y%m%d")
    when "Q2","q2"
      qstart = Date.parse("01-04-" + year).strftime("%Y%m%d")
      qend = Date.parse("30-06-" + year).strftime("%Y%m%d")
    when "Q3","q3"
      qstart = Date.parse("01-07-" + year).strftime("%Y%m%d")
      qend = Date.parse("30-09-" + year).strftime("%Y%m%d")
    when "Q4","q4"
      qstart = Date.parse("01-10-" + year).strftime("%Y%m%d")
      qend = Date.parse("31-12-" + year).strftime("%Y%m%d")
  end
  return qstart,qend
end

#============================================
def pledge_calcs(ptotal,ctotal,initial_gift,pperiod,numperiods,periodicity,progress)
  # used for PCOpledge report

inc_initial_gift = TRUE
# cproject = total campaign projections, from initial gift to pledge end
  # add logic to calculate end of pledge period, and skip below if ended
  # pledge_end = pledge_startdate + (#periods * periodicity)
  # example  : 1/1/2017 + (36 * annual) = 1/1/2020
    ppercent = 0.00 # period % progress start to date
    pproject = 0.00 # period projections (quarterly for weekly, quarterly; annual for annually)
    cpercent = 0.00 # campaign % progress start to date
    cproject = 0.00 # campaign projections from start to date
    cproject = (pperiod * numperiods)
    if inc_initial_gift and !initial_gift.nil?
      cproject += initial_gift
    end

    cproject != 0 ? cpercent = ctotal / cproject : cpercent = 0.00

    case periodicity
      when "weekly"
          # 13 weeks per quarter
          pproject = pperiod * 13
          ppercent = ptotal / pproject
      when "annually"
        # Annual assumes full annual amount projected from beginning of the year
        pproject = pperiod
        ppercent = ptotal / pproject
      when "monthly"
        # 3 months per quarter
        pproject = pperiod * 3
        ppercent = ptotal / pproject
      else
        # i.e. none, or no recurring pledge
        pproject = 0.00
        ppercent = 0.00
        cpercent = 0.00
    end

    return ppercent,pproject,cpercent,cproject

end
#============================================
def get_geoarray()

@geo_array = []
loc_counter = 0
  GeoMap.all.each do | geo |
    if geo.campus_id == "na" # record is person
      loc_counter += 1
      @geo_array << [geo.latitude, geo.longitude,loc_counter.to_s,]
    else  #record is campus
      campus = Campu.where(:campus_id => geo.campus_id)[0].campus_name
      @geo_array << [geo.latitude, geo.longitude,campus]
    end
  end
  return @geo_array
end
