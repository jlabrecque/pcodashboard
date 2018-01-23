
require 'pco_api'
require 'rubygems'
require 'json'
require 'date'
require 'graticule'
require 'calendar_methods.rb'

@settings = Setting.x

#General Variables

eml_subject = @settings.site_name
eml_body    = ""
$pullcount_max = @settings.pullcount_max #max # of api pulls to commit before sleep
$rate_interval = @settings.rate_interval # interval(sec) to calculate rate window - currently 100 requests every 20 seconds (june 2017)
$exceptionbuffer = @settings.exceptionbuffer # # of seconds to add to rate limit exceptions
$sleepbuffer = @settings.sleepbuffer # # of seconds to add to rate limit sleep

# API Test
def pcoapitest(t,s)
  $retry_switch = 1
  # Gets block of people data
  success = true
  api = PCO::API.new(basic_auth_token: t, basic_auth_secret: s)
  begin
    people_unp = api.people.v2.people.get()
  rescue PCO::API::Errors::BaseError => error
    response = error
    success = false
  end
    if success
      response = JSON.parse(people_unp.to_json)
    else
      response = error
    end

  return success,response

end

def admin_email()
  @eml_address = @settings.admin_email
  return @eml_address
end

def campus_fd()
  @campus_fd = @settings.campus_fd
  return @campus_fd
end

# People Pull
def people(page_size,offset_index)
  $retry_switch = 1
  script_name="people_dbload.rb/people"
  # Gets block of people data
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    people_unp = api.people.v2.people.get(per_page: page_size,offset: offset_index,include: 'location', order: 'remote_id')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(people_unp.to_json)
end

def person(pco_id)
  $retry_switch = 1
  script_name="people_dbload.rb/person"
  # Gets single person data
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    person_unp = api.people.v2.people[pco_id].get(include: 'emails,phone_numbers,addresses,households')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  if $retry_switch == 1
        return JSON.parse(person_unp.to_json)
  end
end

def find_person_email(target_email)
      target_id = 0
      Person.all.each do |ppl|
      if !ppl.email_array.nil?
        address_exists = ppl.email_array.detect {|f| f["address"] == target_email}
        if address_exists
          target_id = ppl.id
        end
      end
    end
    return target_id
end

def find_person_campus(pco_id)
  if !@settings.campus_fd.empty?
      script_name="people_dbload.rb/campus"
      #### Field Definition SPECIFIC to Community Christian PCO instance custom tabs
      target_fd = @settings.campus_fd
      # Gets single person data
      api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
      begin
        person_unp = api.people.v2.people[pco_id].field_data.get(include: 'field_definition')
      rescue PCO::API::Errors::BaseError => error
        $retry_switch = exception_pause(error,script_name)
        retry if $retry_switch == 1
      end
      fd = JSON.parse(person_unp.to_json)["data"]
      campus = ""
        fd.each do |f|
        fd_id = f["relationships"]["field_definition"]["data"]["id"]
          if fd_id == target_fd
            campus = f["attributes"]["value"]
          end
        end
      if !campus.empty? #to determine id value
          c = Campu.where(:campus_name => campus)
          campus_id = c[0].id
      end
      return campus,campus_id
  else  #no defined fd, use single default value
    campus = "Main Campus"
    campus_id = 1
    return campus,campus_id
  end
end

# PCO API pull of PCO Giving / People / Donations
def get_donations(page_size,offset_index)
  script_name="donations_dbload2.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
      donations_unp = api.giving.v2.donations.get(per_page: page_size,offset: offset_index,include: 'designations')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(donations_unp.to_json)
end

# PCO API pull of PCO Giving / Donations / Designations
def designations(donid)
  script_name="donations_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    designations_unp = api.giving.v2.donations[donid].designations.get(include: 'fund')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  ####################REMOVE
  #pp JSON.parse(designations_unp.to_json)
    ####################REMOVE
  return JSON.parse(designations_unp.to_json)

end

def funds()
  script_name="donations_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    funds_unp = api.giving.v2.funds.get()
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  return JSON.parse(funds_unp.to_json)
end

def events()
  script_name="events_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    events_unp = api.check_ins.v2.events.get()
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(events_unp.to_json)

end

def eventtimes(page_size,offset_index)
  script_name="eventtimes_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    eventtimes_unp = api.check_ins.v2.event_times.get(per_page: page_size,offset: offset_index, include: 'event')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(eventtimes_unp.to_json)
end



def service_type()
  script_name="volunteer_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    servicetype_unp = api.services.v2.service_types.get()
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(servicetype_unp.to_json)
end

def checkins(page_size,offset_index)
  script_name="checkins_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    checkins_unp = api.check_ins.v2.check_ins.get(order: 'updated_at',per_page: page_size,offset: offset_index,include: 'location,event_times')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(checkins_unp.to_json)
end

def check(checkid)
  script_name="checkins_dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    check_unp = api.check_ins.v2.check_ins[checkid].get(include: 'location,event,event_times,person')
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(check_unp.to_json)
end

def service_types()
  script_name="services-dbload.rb"
  # Gets all service types (should be one pull)
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    service_type_unp = api.services.v2.service_types.get()
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(service_type_unp.to_json)
end

def plans(stid,page_size_pl,offset_index_pl)
  script_name="services-dbload.rb"
  # Gets all plans related to a service type
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    plans_unp = api.services.v2.service_types[stid].plans.get(per_page: page_size_pl,offset: offset_index_pl)
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(plans_unp.to_json)
end

def team_members(stid,plid,page_size,offset_index)
  script_name="services-dbload.rb"
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    team_members_unp = api.services.v2.service_types[stid].plans[plid].team_members.get(per_page: page_size,offset: offset_index)
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  if $retry_switch == 3
    $retry_switch = 0
    return NIL
  else
    return JSON.parse(team_members_unp.to_json)
  end

end
# lists methods
def lists(page_size,offset_index)
  script_name="unused"
  # Gets all team members related to a specific plan
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    lists_unp = api.people.v2.lists.get(per_page: page_size,offset: offset_index)
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(lists_unp.to_json)
end
def listpeople(lid,page_size,offset_index)
  script_name="unused"
  # Gets all team members related to a specific plan
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  begin
    listpeople_unp = api.people.v2.lists[lid].people.get(per_page: page_size,offset: offset_index)
  rescue PCO::API::Errors::BaseError => error
    $retry_switch = exception_pause(error,script_name)
    retry if $retry_switch == 1
  end
  $pullcount += 1
  rate_check()
  return JSON.parse(listpeople_unp.to_json)
end

#Build CampusDb methods
def campus_load()
  script_name="people-dbload.rb"
  # Gets all service types (should be one pull)
  if !@settings.campus_fd.empty?
      api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
      begin
        campus_unp = api.people.v2.field_definitions[@settings.campus_fd].field_options.get()
      rescue PCO::API::Errors::BaseError => error
        $retry_switch = exception_pause(error,script_name)
        retry if $retry_switch == 1
      end
      return JSON.parse(campus_unp.to_json)
  end
end

#Workflow method
def workflows(page_size,offset_index)
  script_name="workflows-dbload.rb"
  # Gets all service types (should be one pull)
      api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
      begin
        workflows_unp = api.people.v2.workflows.get(per_page: page_size,offset: offset_index,include: 'steps')
      rescue PCO::API::Errors::BaseError => error
        $retry_switch = exception_pause(error,script_name)
        retry if $retry_switch == 1
      end
      return JSON.parse(workflows_unp.to_json)
end

#Workflowcard method
def workflowcards(wf,page_size,offset_index)
  script_name="workflowcards-dbload.rb"
  # Gets all service types (should be one pull)
      api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
      begin
        workflowcards_unp = api.people.v2.workflows[wf].cards.get(per_page: page_size,offset: offset_index)
      rescue PCO::API::Errors::BaseError => error
        $retry_switch = exception_pause(error,script_name)
        retry if $retry_switch == 1
      end
      return JSON.parse(workflowcards_unp.to_json)
end

#Workflowcardnote method
def workflowcardnotes(wf,wfc,page_size,offset_index)
  script_name="workflowcardotes-dbload.rb"
  # Gets all service types (should be one pull)
      api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
      begin
        workflowcardnotes_unp = api.people.v2.workflows[wf].cards[wfc].notes.get(per_page: page_size,offset: offset_index)
      rescue PCO::API::Errors::BaseError => error
        $retry_switch = exception_pause(error,script_name)
        retry if $retry_switch == 1
      end
      return JSON.parse(workflowcardnotes_unp.to_json)
end

#Geocoding methods
def geocode_people(id,street,city,state,zip)
  geocoder = Graticule.service(:google).new @settings.googlemaps_api
  sleep(1)
  mode = ""
  if street.blank? and city.blank? and state.blank? and zip.blank? # no entries, address all blank
    mode = "blank"
  elsif street.blank? or city.blank? or state.blank? or zip.blank? #something blank
      if street.blank? and !city.blank? and !state.blank? and !zip.blank? #city, state, zip
        mode = "csz"
      elsif  street.blank? and !city.blank? and !state.blank? and zip.blank? #city, state, no zip
        mode = "cs"
      else # just state?
        mode = "s"
      end
  end
  case mode
      when "blank"
          address = ""
      when "csz"
          address = "#{city}, #{state}  #{zip}"
      when "cs"
          address = "#{city}, #{state}"
      when "s"
          address = ""
      else
          address = "#{street}, #{city}, #{state}  #{zip}" #full address
      end
  if !address.blank?
    begin
        location = geocoder.locate(address)
    rescue Graticule::AddressError => error
        puts "Error was: #{error}"
        location = nil
    rescue Graticule::Error => error
        puts "Error was: #{error}"
        location = nil
    end
    if !location.nil?
      long = location.longitude
      lat = location.latitude
    end
  end
  return address,long,lat
end

#custom tab walker
def custom_tab_walker(t,s)
api = PCO::API.new(basic_auth_token: t, basic_auth_secret: s )
  tab_array = []
  tabs_unp = api.people.v2.tabs.get()
  tabs = JSON.parse(tabs_unp.to_json)

  tabs["data"].each do |t|
    tab_array << "====Tab_Id:#{t["id"]}  Name:#{t["attributes"]["name"]}"
    field_definitions_unp = api.people.v2.tabs[t["id"]].get(include: 'field_definitions')
    field_definitions = JSON.parse(field_definitions_unp.to_json)
    field_definitions["included"].each do |fd|
        tab_array << "========** FD_Id:#{fd["id"]}  Type:#{fd["attributes"]["data_type"]}  Name:#{fd["attributes"]["name"]}"
        field_options_unp = api.people.v2.field_definitions[fd["id"]].field_options.get()
        field_options = JSON.parse(field_options_unp.to_json)
        field_options["data"].each do |fo|
          tab_array << "========**====== Value:#{fo["attributes"]["value"]}"
        end
    end
  end
  return tab_array
end
#rate limit management methods

def rate_check()
  # max count before rate check pause
  if $pullcount > $pullcount_max
    # time to check if exceeding rate
    if $endtime > Time.now
      # if less than 1min expired, calc seconds and sleep
      sleepval = ($endtime - Time.now) + $sleepbuffer
      puts "Approaching rate limit .. Sleeping for #{sleepval.ceil}"
      sleep(sleepval.ceil)
   end
   # in either case, reset clock and pullcount
   set_endtime()
   #reset pullcount
   $pullcount = 0
  end
end

def set_endtime()
  $endtime = Time.now + $rate_interval
end

def exception_pause(error,script_name)
      #Called from a exception check that received a RateExceed error back from the API
      # Method resets (longer) sleep value, notifies user (console), sleeps for X, then resets the clock and pullcount
      case error.status
      when 429
          puts "429 Exception occured...#{error.message}"
          sleepval = ($endtime - Time.now)
          if sleepval < 0
              puts "Rate limit exceded .. Sleeping for #{$exceptionbuffer}"
              sleep($exceptionbuffer)
          else
              puts "Rate limit exceded .. Sleeping for #{sleepval.ceil}"
              sleep(sleepval.ceil)
          end
          puts "Recovery complete -- continuing processing"
          $endtime = Time.now + 60
          $pullcount = 0
          $retry_switch = 1
      when 404
        puts "404 Exception occured...#{error.message}"
        $retry_switch = 3
      else
          puts "Non-recoverable non-rate error. Sorry!!..#{error.message}"
          $retry_switch = 0
      end
      return $retry_switch
end

def remove_non_ascii(input)
 input = input.gsub(/[\u0080-\u00ff]/, " ")
 return input
end

### Mailchimp update to PCO methods
def generate_mchash_local()

  # Example  @mc_array = {
  #            {"emailaddress" =>  {"status" => {"code" => @settings.mc_status_fd,"value" => "subscribed", "fielddatum" => ""},
  #             "email"  => {"code" => @settings.mc_cleanunsubaddress_fd, "value" => email, "fielddatum" => ""},
  #             "date"   => {"code" => @settings.mc_cleanunsubdate_fd,"value" => "2016-09-01",   "fielddatum" => ""}, "pids" => []}
  #           }
    mc_hash = {}
    state = {}
    #iterate through list and set based on current
    Mailchimplist.unsubscribed.each do |unsubscribed|
            state = {"status" => {"code" => @settings.mc_status_fd,"value" => unsubscribed.status, "fielddatum" => ""},
                     "email"  => {"code" => @settings.mc_cleanunsubaddress_fd, "value" => unsubscribed.email_address, "fielddatum" => ""},
                     "date"   => {"code" => @settings.mc_cleanunsubdate_fd,    "value" => unsubscribed.updated_at.strftime("%m/%d/%Y"),   "fielddatum" => ""}, "pids" => []}
            mc_hash.merge!({ unsubscribed.email_address => state })
    end

    Mailchimplist.cleaned.each do |cleaned|
      state = {"status" => {"code" => @settings.mc_status_fd,"value" => cleaned.status, "fielddatum" => ""},
               "email"  => {"code" => @settings.mc_cleanunsubaddress_fd, "value" => cleaned.email_address, "fielddatum" => ""},
               "date"   => {"code" => @settings.mc_cleanunsubdate_fd,    "value" => cleaned.updated_at.strftime("%d/%m/%Y"),   "fielddatum" => ""}, "pids" => []}
            mc_hash.merge!({ cleaned.email_address => state })
    end
    return mc_hash
end


def check_mc_status_local(email)

end

def check_mc_status_pco(mc_hash,email)

  script_name="check_mc_status_pco"
     api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
         begin
           people_unp = api.people.v2.people.get(where: { search_name_or_email: email })
         rescue PCO::API::Errors::BaseError => error
           $retry_switch = exception_pause(error,script_name)
           retry if $retry_switch == 1
         end
     $pullcount += 1
     rate_check()
     people = JSON.parse(people_unp.to_json)
     people["data"].each do |ppl|
        # need to do per record pull (pid) to gather field data
        begin
          person_unp = api.people.v2.people[ppl["id"]].get(include: 'field_data')
        rescue PCO::API::Errors::BaseError => error
          $retry_switch = exception_pause(error,script_name)
          retry if $retry_switch == 1
        end
        $pullcount += 1
        rate_check()
        mc_hash[email]["pids"] << ppl["id"]
        person = JSON.parse(person_unp.to_json)
        person["included"].each do |p|

          case p["attributes"]["field_definition_id"].to_s
          when  mc_hash[email]["status"]["code"]
            if p["attributes"]["value"] != mc_hash[email]["status"]["value"]
              mc_hash[email]["status"]["fielddatum"] = p["id"]
            else
              mc_hash[email]["status"]["fielddatum"] = "nc"
            end

          when  mc_hash[email]["email"]["code"]
            if p["attributes"]["value"] != mc_hash[email]["email"]["value"]
              mc_hash[email]["email"]["fielddatum"] = p["id"]
            else
              mc_hash[email]["email"]["fielddatum"] = "nc"
            end

          when  mc_hash[email]["date"]["code"]
              if p["attributes"]["value"] != mc_hash[email]["date"]["value"]
                mc_hash[email]["date"]["fielddatum"] = p["id"]
              else
                mc_hash[email]["date"]["fielddatum"] = "nc"
              end
          end
    end
  end
  #pp mc_hash
  return mc_hash
end

def set_mc_status_pco(mc_hash)
  script_name="set_mc_status_pco"

   api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )

  mc_hash.each do |mc| # iterate through people in array
    email = mc[0]
          pids = mc[1]["pids"]
          pids.each do |pid|
            mc[1].each do |m|
              if m[0] != "pids"

              if  m[1]["fielddatum"] == "nc" # value same, no change
                 puts "Value same, no change"

              elsif !m[1]["fielddatum"].empty? # not empty = Fielddatum, exists, need to patch
                  puts "Patching #{pid}"
              begin
                  api.people.v2.people[pid].field_data[m[1]["fielddatum"]].patch(data:
                        { type: "FieldDatum", id: m[1]["fielddatum"],
                            attributes: { value: m[1]["value"]},
                            relationships: {field_definition:
                                {data: {type: "FieldDefinition",id: m[1]["code"]}
                                }
                            }
                        }
                    )
              rescue PCO::API::Errors::BaseError => error
                    $retry_switch = exception_pause(error,script_name)
                    retry if $retry_switch == 1
                  end
                  $pullcount += 1
                  rate_check()
             else
               puts "Posting #{pid}"
                  begin
                    api.people.v2.people[pid].field_data.post(data:
                        { type: "FieldDatum",
                            attributes: { value: m[1]["value"]},
                            relationships: {field_definition:
                                {data: {type: "FieldDefinition",id: m[1]["code"]}
                                }
                            }
                        }
                    )
                  rescue PCO::API::Errors::BaseError => error
                    $retry_switch = exception_pause(error,script_name)
                    retry if $retry_switch == 1
                  end
                  $pullcount += 1
                  rate_check()
          end
        end
      end
    end
  end
end

# Household Giving report
def household_giving_report()

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
      @person_id = h.person_id
      h.members.each do |hm|
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
                :month1             =>    @montotals_a[@montotals_count - 12][0],
                :month1gift         =>    d[6][@montotals_count - 12][1],
                :month2             =>    @montotals_a[@montotals_count - 11][0],
                :month2gift         =>    d[6][@montotals_count - 11][1],
                :month3             =>    @montotals_a[@montotals_count - 10][0],
                :month3gift         =>    d[6][@montotals_count - 10][1],
                :month4             =>    @montotals_a[@montotals_count - 9][0],
                :month4gift         =>    d[6][@montotals_count - 9][1],
                :month5             =>    @montotals_a[@montotals_count - 8][0],
                :month5gift         =>    d[6][@montotals_count - 8][1],
                :month6             =>    @montotals_a[@montotals_count - 7][0],
                :month6gift         =>    d[6][@montotals_count - 7][1],
                :month7             =>    @montotals_a[@montotals_count - 6][0],
                :month7gift         =>    d[6][@montotals_count - 6][1],
                :month8             =>    @montotals_a[@montotals_count - 5][0],
                :month8gift         =>    d[6][@montotals_count - 5][1],
                :month9             =>    @montotals_a[@montotals_count - 4][0],
                :month9gift         =>    d[6][@montotals_count - 4][1],
                :month10            =>    @montotals_a[@montotals_count - 3][0],
                :month10gift        =>    d[6][@montotals_count - 3][1],
                :month11            =>    @montotals_a[@montotals_count - 2][0],
                :month11gift        =>    d[6][@montotals_count - 2][1],
                :month12            =>    @montotals_a[@montotals_count - 1][0],
                :month12gift        =>    d[6][@montotals_count - 1][1],
                :annavg         =>    annavg,
                :lastqtravg     =>    lastqrtavg
              )
          end
    end
    prime = Metum.create(:modeltype => "hgift", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0, :last_import => Date.today)
    csvfilename = household_giving_csv()
    Metum.update(prime.id,:last_id_imported => csvfilename)
end

def household_giving_csv()

  datestamp = Metum.hgifts.last.last_import
  csvfilename = "Household_Giving_#{datestamp.strftime ("%y%m%d%H%M")}.csv"

  CSV.open("public/reports/#{csvfilename}", "w") do |csv|

      m = Hgift.last
      header = ["Last Name","First Name","Family","Campus",m.month1,m.month2,m.month3,m.month4,m.month5,m.month6,m.month7,m.month8,m.month9,m.month10,m.month11,m.month12]
      csv << header

      Hgift.all.each do |h|
        lname     = h.last_name
        fname     = h.first_name
        family    = h.family
        campus    = h.campus
        month1    = h.month1gift
        month2    = h.month2gift
        month3    = h.month3gift
        month4    = h.month4gift
        month5    = h.month5gift
        month6    = h.month6gift
        month7    = h.month7gift
        month8    = h.month8gift
        month9    = h.month9gift
        month10   = h.month10gift
        month11   = h.month11gift
        month12   = h.month12gift
        line = [lname,fname,family,campus,month1,month2,month3,month4,month5,month6,month7,month8,month9,month10,month11,month12]
        csv << line
      end
  end
  return csvfilename
end
