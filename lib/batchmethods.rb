
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
def email_selected(ids,inputs)
    emails = []
    noemails = []

    if inputs["subject"].empty? or inputs["content"].empty?
        response = "No email content was entered, so none sent."
    else

        if inputs['to'] == "Yourself"
          PcocoreMailer.send_email(current_admin_user.email,current_admin_user.email,inputs["subject"],inputs["content"]).deliver
        else
          ids.each do |pid|
              p = Person.find(pid.to_i)
              if !p.email.empty?
                 PcocoreMailer.send_email(current_admin_user.email,p.email,inputs["subject"],inputs["content"]).deliver
    #             logger.info("Email detail: #{pid}, #{p.fullname}, #{p.email}, #{inputs["subject"]}, #{inputs["content"]}")

              else
                 noemails << p.fullname
                 logger.info("Noemail for: #{p.fullname}")
              end
          end
        end
        if !noemails.empty?
            noem = ", except #{noemails} (No email addresses)"
        else
            noem = "."
        end
        response =  "Emails sent" + noem
    end

    return response

end

def email_selected_hgift(ids,inputs)
  ## ids will be Hgift IDs -- need to convert into Person IDs
  newids = []
  ids.each do |hgift|
    p = Hgift.where(:id => hgift) #gets the Hgift record
    newids << p[0].person_id
  end
  response = email_selected(newids,inputs)
  return response
end
