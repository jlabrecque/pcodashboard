class MailchimpListsLoad < ActiveJob::Base
  def perform
    result = %x(bin/rails runner "lib/mailchimplist-dbload.rb update")
  end
end
