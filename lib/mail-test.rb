require 'rubygems'

#If cli parms not passed, so update from last offset ...
  if ARGV.count == 1
    eml_subject = "Another test email"
    eml_body    = "This is the body of the sample email I am contructing and want to expand this a bit.... blah, blah, blah"
    PcocoreMailer.send_email(ARGV.first,eml_subject,eml_body).deliver
  else
    puts "======================================================================"
    puts "mail-test requires at least one parameter for the target email address"
    puts "Example: rails runner lib/mail-test.rb <targetemailaddress>"
    puts "======================================================================"

  end
