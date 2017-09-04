class PcocoreMailer < ApplicationMailer
  default from: "smtpout@community-christian.us"

#  def sample_email(user)
#    @user = user
#    mail(to: @user.email, subject: 'Sample Email')
#    mail(to: "dhockenberry@gmail.com", subject: 'Sample Email')
# end

  def send_email(eml_address,eml_subject,eml_body)
#    @user = user
    mg_client = Mailgun::Client.new ENV['MAILGUN_API']
    message_params = {:from    => ENV['MAILGUN_USERNAME'],
                      :to      => eml_address,
                      :subject => eml_subject,
                      :text    => eml_body
                    }
    mg_client.send_message ENV['MAILGUN_DOMAIN'], message_params
  end
end
