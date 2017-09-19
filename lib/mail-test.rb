require 'rubygems'
require 'pp'
require 'date'
require 'pcocore_api.rb'

pid = 19468223
page_size = 25
offset_index = 0
next_check = 0
$pullcount = 0
$endtime = Time.now + 60

eml_address = "dhockenberry@gmail.com"
eml_subject = "Another test email"
eml_body    = "This is the body of the sample email I am contructing and want to expand this a bit.... blah, blah, blah"

PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
