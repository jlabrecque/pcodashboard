require 'pco_api'
require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'dotenv'
require 'dotenv-rails'
require 'pcocore_api.rb'

#CONSTANTS
page_size = 100
sleepval = 0
lastdonationid = ""
$pullcount = 0
datestamp = Time.now
$endtime = Time.now + 60

more = 0
total = 0
pullcount = 0
pullcount_max = 95
endtime = Time.now + 60
donreportarray = []
annavg = 0.0
lastqrtavg = 0.0
lastmntavg = 0.0
#Start ...
puts "Processing Households..."
Household.all.each do |h|
  family = h.household_name
  @pco_id = h.household_id_pco
  @montotals = {}
  @montotals.default_proc = proc { 0 }
  @campus = h.primary.campus
  @last_name = h.primary.last_name
  @first_name = h.primary.first_name
  h.members.each do |hm|
      @person_id = hm.id
      @calendar,@lastsunday = get_calendar()
      stuff_tithe(hm.pco_id,@calendar)
            @calendar.each do |k,v|
              mmonth = v[:date].strftime("%m")
              case mmonth
                when "01"
                  mkey = "Jan_" + v[:date].strftime("%y")
                when "02"
                  mkey = "Feb_" + v[:date].strftime("%y")
                when "03"
                  mkey = "Mar_" + v[:date].strftime("%y")
                when "04"
                  mkey = "Apr_" + v[:date].strftime("%y")
                when "05"
                  mkey = "May_" + v[:date].strftime("%y")
                when "06"
                  mkey = "Jun_" + v[:date].strftime("%y")
                when "07"
                  mkey = "Jul_" + v[:date].strftime("%y")
                when "08"
                  mkey = "Aug_" + v[:date].strftime("%y")
                when "09"
                  mkey = "Sep_" + v[:date].strftime("%y")
                when "10"
                  mkey = "Oct_" + v[:date].strftime("%y")
                when "11"
                  mkey = "Nov_" + v[:date].strftime("%y")
                when "12"
                  mkey = "Dec_" + v[:date].strftime("%y")
                end
              @montotals[mkey] += v[:amount]
            end
  end
  @montotals_a = @montotals.to_a
  @montotals_count = @montotals_a.count
  donreportarray << [@person_id,@pco_id,@last_name,@first_name,@campus,family,@montotals_a]
end
puts "Starting People..."

  Person.all.each do |p|
  if p.family.empty?
      @calendar,@lastsunday = get_calendar()
        stuff_tithe(p.pco_id,@calendar)
              family = p.last_name + ", " + p.first_name + "*"
              @montotals = {}
              @montotals.default_proc = proc { 0 }
              @calendar.each do |k,v|
                mmonth = v[:date].strftime("%m")
                case mmonth
                  when "01"
                    mkey = "Jan_" + v[:date].strftime("%y")
                  when "02"
                    mkey = "Feb_" + v[:date].strftime("%y")
                  when "03"
                    mkey = "Mar_" + v[:date].strftime("%y")
                  when "04"
                    mkey = "Apr_" + v[:date].strftime("%y")
                  when "05"
                    mkey = "May_" + v[:date].strftime("%y")
                  when "06"
                    mkey = "Jun_" + v[:date].strftime("%y")
                  when "07"
                    mkey = "Jul_" + v[:date].strftime("%y")
                  when "08"
                    mkey = "Aug_" + v[:date].strftime("%y")
                  when "09"
                    mkey = "Sep_" + v[:date].strftime("%y")
                  when "10"
                    mkey = "Oct_" + v[:date].strftime("%y")
                  when "11"
                    mkey = "Nov_" + v[:date].strftime("%y")
                  when "12"
                    mkey = "Dec_" + v[:date].strftime("%y")
                  end
                @montotals[mkey] += v[:amount]
              end
              @montotals_a = @montotals.to_a
              @montotals_count = @montotals_a.count
              donreportarray << [p.id,p.pco_id,p.last_name,p.first_name,p.campus,family,@montotals_a]
       end
    end
# #stuff header

    csv = []
    puts "Stuffing array header..."
    csv << ["Person ID","PCO_ID","Last Name","First Name","Campus","Family",
      @montotals_a[@montotals_count - 12][0],
      @montotals_a[@montotals_count - 11][0],
      @montotals_a[@montotals_count - 10][0],
      @montotals_a[@montotals_count - 9][0],
      @montotals_a[@montotals_count - 8][0],
      @montotals_a[@montotals_count - 7][0],
      @montotals_a[@montotals_count - 6][0],
      @montotals_a[@montotals_count - 5][0],
      @montotals_a[@montotals_count - 4][0],
      @montotals_a[@montotals_count - 3][0],
      @montotals_a[@montotals_count - 2][0],
      @montotals_a[@montotals_count - 1][0]
    ]

    # Delete all existing HouseholdGiving records
    Hgift.delete_all
    puts "Deleting old HouseholdGiving records..."
    puts "Processing donations arrays..."
    donreportarray.each do |d|

      sum =
      ((d[6][@montotals_count - 12][1])) +
      ((d[6][@montotals_count - 11][1])) +
      ((d[6][@montotals_count - 10][1])) +
      ((d[6][@montotals_count - 9][1])) +
      ((d[6][@montotals_count - 8][1])) +
      ((d[6][@montotals_count - 7][1])) +
      ((d[6][@montotals_count - 6][1])) +
      ((d[6][@montotals_count - 5][1])) +
      ((d[6][@montotals_count - 4][1])) +
      ((d[6][@montotals_count - 3][1])) +
      ((d[6][@montotals_count - 2][1])) +
      ((d[6][@montotals_count - 1][1]))

      if sum > 0
            annavg = sum/12
            lastqrtavg =
                  ((d[6][@montotals_count - 3][1]) +
                  (d[6][@montotals_count - 2][1]) +
                  (d[6][@montotals_count - 1][1]))/3
          csv << [d[0],d[1],d[2],d[3],d[4],d[5],
            (d[6][@montotals_count - 12][1]),
            (d[6][@montotals_count - 11][1]),
            (d[6][@montotals_count - 10][1]),
            (d[6][@montotals_count - 9][1]),
            (d[6][@montotals_count - 8][1]),
            (d[6][@montotals_count - 7][1]),
            (d[6][@montotals_count - 6][1]),
            (d[6][@montotals_count - 5][1]),
            (d[6][@montotals_count - 4][1]),
            (d[6][@montotals_count - 3][1]),
            (d[6][@montotals_count - 2][1]),
            (d[6][@montotals_count - 1][1]),
            annavg, lastqrtavg
          ]



          # # Create new HouseholdGiving record set based on report output
          newrec = Hgift.create(
            :person_id      =>    d[0],
            :pco_id         =>    d[1],
            :last_name      =>    d[2],
            :first_name     =>    d[3],
            :campus         =>    d[4],
            :family         =>    d[5],
            :month1         =>    [@montotals_a[@montotals_count - 12][0] , d[6][@montotals_count - 12][1] ],
            :month2         =>    [@montotals_a[@montotals_count - 11][0] , d[6][@montotals_count - 11][1] ],
            :month3         =>    [@montotals_a[@montotals_count - 10][0] , d[6][@montotals_count - 10][1] ],
            :month4         =>    [@montotals_a[@montotals_count - 9][0] , d[6][@montotals_count - 9][1] ],
            :month5         =>    [@montotals_a[@montotals_count - 8][0] , d[6][@montotals_count - 8][1] ],
            :month6         =>    [@montotals_a[@montotals_count - 7][0] , d[6][@montotals_count - 7][1] ],
            :month7         =>    [@montotals_a[@montotals_count - 6][0] , d[6][@montotals_count - 6][1] ],
            :month8         =>    [@montotals_a[@montotals_count - 5][0] , d[6][@montotals_count - 5][1] ],
            :month9         =>    [@montotals_a[@montotals_count - 4][0] , d[6][@montotals_count - 4][1] ],
            :month10        =>    [@montotals_a[@montotals_count - 3][0] , d[6][@montotals_count - 3][1] ],
            :month11        =>    [@montotals_a[@montotals_count - 2][0] , d[6][@montotals_count - 2][1] ],
            :month12        =>    [@montotals_a[@montotals_count - 1][0] , d[6][@montotals_count - 1][1] ],
            :annavg         =>    annavg,
            :lastqtravg     =>    lastqrtavg

          )


          # @newrec = [
          #   d[0],d[1],
          #   {@montotals_a[@montotals_count - 12][0] => d[6][@montotals_count - 12][1] },
          #   {@montotals_a[@montotals_count - 11][0] => d[6][@montotals_count - 11][1] },
          #   {@montotals_a[@montotals_count - 10][0] => d[6][@montotals_count - 10][1] },
          #   {@montotals_a[@montotals_count - 9][0] => d[6][@montotals_count - 9][1] },
          #   {@montotals_a[@montotals_count - 8][0] => d[6][@montotals_count - 8][1] },
          #   {@montotals_a[@montotals_count - 7][0] => d[6][@montotals_count - 7][1] },
          #   {@montotals_a[@montotals_count - 6][0] => d[6][@montotals_count - 6][1] },
          #   {@montotals_a[@montotals_count - 5][0] => d[6][@montotals_count - 5][1] },
          #   {@montotals_a[@montotals_count - 4][0] => d[6][@montotals_count - 4][1] },
          #   {@montotals_a[@montotals_count - 3][0] => d[6][@montotals_count - 3][1] },
          #   {@montotals_a[@montotals_count - 2][0] => d[6][@montotals_count - 2][1] },
          #   {@montotals_a[@montotals_count - 1][0] => d[6][@montotals_count - 1][1] },
          #   annavg,lastqrtavg
          #
          # ]
      end
end
pp @newrec

puts "Done!"
