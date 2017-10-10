require 'rubygems'
require 'json'
require 'pp'
require 'csv'
import = 'lib/import/campaign_import.csv'

totcreated = 0
puts "Starting processing..."
puts "Opening CSV file for read..."

CSV.foreach(import, headers: true) do |row|
  campaign = row.to_hash

  pinput = Campaign.create(
  :campaign_id                => campaign['campaign_id'],
  :campaign_name              => campaign['campaign_name'],
  :fund_id_pco                => campaign['fund_id']
  )

puts "Processing Campaign for ID #{campaign["campaign_id"]}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
