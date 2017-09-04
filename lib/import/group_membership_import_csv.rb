require 'rubygems'
require 'json'
require 'pp'
require 'csv'

csvfile = "lib/archive/dummy_group_membership.csv"

totcreated = 0
puts "Starting processing..."
puts "Opening CSV file for read..."

CSV.foreach(csvfile, headers: true) do |row|
  groupm = row.to_hash

  input = GroupMembership.create(
  :group_id           => groupm['group_id'],
  :person_id          => groupm['person_id'],
  :leader             => groupm['leader'],
  :started            => groupm['started'],
  :ended              => groupm['ended']
    )

puts "Processing Member: #{groupm['person_id']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
