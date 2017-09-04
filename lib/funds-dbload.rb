require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'

#CONSTANTS
logfile_prefix = "funds"
offset_index = 0
page_size = 50
sleepval = 30
totprocessed = 0
totcreated = 0
totupdated = 0
datestamp = Time.now
logfile = "log/#{logfile_prefix}_dbload_#{datestamp.strftime("%y%m%d%H%M")}.log"
logoptions = "w"
eml_address = admin_email()
eml_subject = "#{logfile_prefix}_dbload logfile #{datestamp}"
open_log =  File.open(logfile, logoptions )
open_log.puts("=============================================================")
open_log.puts("Script started at #{datestamp}")
open_log.puts("=============================================================")
open_log.puts("funds_dbload.rb is a Ruby script to load the current ")
open_log.puts("Planning Center funds data within the churches account")
open_log.puts("using the PCO API. The script checks the API collected data ")
open_log.puts("against the current local database data, creates new records")
open_log.puts("when they dont exist, update if record has been updated since")
open_log.puts("the last API pull, and skips duplicates")
open_log.puts(" ")
open_log.puts("Planning Center rate limits API pulls to 100 per minute, so")
open_log.puts("the script also counts the API pulls against a 1 minute")
open_log.puts("counter, and if approach the rate limit, will sleep the")
open_log.puts("script to keep within the limit")
open_log.puts("=============================================================")

open_log.puts("Starting processing...")

fnd = funds()
inner_loop_index = 0
fnd["data"].each do |u|
  fndcheck = Fund.where(:fund_id => u["id"])
  if !fndcheck.exists?
      open_log.puts("Creating new record")
      fundpost = Fund.create(
          :fund_id                  =>  u["id"],
          :name                     =>  u["attributes"]["name"],
          :description              =>  u["attributes"]["description"],
          :fund_updated_at          =>  u["attributes"]["updated_at"]
      )
      totcreated += 1
    elsif  !(fndcheck[0].fund_updated_at == u["attributes"]["updated_at"])
      open_log.puts("Updating existing record")
      fundpost = ServiceType.update(
          :fund_id                  =>  u["id"],
          :name                     =>  u["attributes"]["name"],
          :description              =>  u["attributes"]["description"],
          :fund_updated_at          =>  u["attributes"]["updated_at"]
      )
      else
        open_log.puts("*** No action ***")
      end
      inner_loop_index += 1
end

open_log.puts("** All records processed  **")
open_log.puts("Total created: #{totcreated}")
open_log.puts("=============================================================")
open_log.puts("Script ended at #{datestamp}")
open_log.puts("=============================================================")
open_log.close

eml_body = File.read(logfile)
PcocoreMailer.send_email(eml_address,eml_subject,eml_body).deliver
