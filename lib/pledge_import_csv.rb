require 'rubygems'
require 'json'
require 'pp'
require 'csv'

totcreated = 0
puts "Starting processing..."
puts "Opening CSV file for read..."

CSV.foreach('lib/import/pledge_import.csv', headers: true) do |row|
  pledge = row.to_hash

  pinput = Pledge.create(
  :campaign             => pledge['campaign'],
  :pledge_date          => pledge['pledge_date'],
  :pco_id               => pledge['pco_id'],
  :fname                => pledge['fname'],
  :lname                => pledge['lname'],
  :pco_id2              => pledge['pco_id2'],
  :fname2               => pledge['fname2'],
  :lname2               => pledge['lname2'],
  :family_id            => pledge['family_id'],
  :initial_gift         => pledge['initial_gift'],
  :pledge_perperiod     => pledge['pledge_perperiod'],
  :pledge_periods       => pledge['pledge_periods'],
  :periodicity          => pledge['periodicity'],
  :pledge_start         => pledge['pledge_start']
  )

puts "Processing Pledge for PCO_ID #{pledge['pco_id']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} pledge records processed"
