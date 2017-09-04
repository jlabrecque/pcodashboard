require 'rubygems'
require 'json'
require 'pp'
require 'csv'

csvfile = "lib/archive/dummy_groups.csv"

totcreated = 0
puts "Starting processing..."
puts "Opening CSV file for read..."

CSV.foreach(csvfile, headers: true) do |row|
  group = row.to_hash

  input = Group.create(
  :pco_group_id         => group['pco_group_id'],
  :description          => group['description'],
  :category             => group['category'],
  :start                => group['start'],
  :end                  => group['end'],
  :open                 => group['open'],
  :category             => group['category'],
  :group_url            => group['group_url']
  )

puts "Processing Group: #{group['description']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
