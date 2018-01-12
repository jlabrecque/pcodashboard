class PcocoreMailer < ApplicationMailer

  def send_email(eml_from,eml_address,eml_subject,eml_body)
    @settings = Setting.x
    mg_client = Mailgun::Client.new @settings.mailgun_api
    if eml_from.empty?
      from = @settings.mailgun_username
    else
      from = eml_from
    end
    message_params = {:from    => from,
                      :to      => eml_address,
                      :subject => eml_subject,
                      :text    => eml_body
                    }
    result = mg_client.send_message(@settings.mailgun_domain, message_params).to_h!
    logger.info("Mailer result: #{result}; to: #{eml_address}, from:#{from}")

  end
end
