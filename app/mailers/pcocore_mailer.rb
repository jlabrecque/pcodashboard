class PcocoreMailer < ApplicationMailer

settings = Setting.x

  def send_email(eml_address,eml_subject,eml_body)
    mg_client = Mailgun::Client.new settings.mailgun_api
    message_params = {:from    => settings.mailgun_username,
                      :to      => eml_address,
                      :subject => eml_subject,
                      :text    => eml_body
                    }
    mg_client.send_message settings.mailgun_domain, message_params
  end
end
