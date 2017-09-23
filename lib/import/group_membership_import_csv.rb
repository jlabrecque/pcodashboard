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
  p = Person.where(:pco_id => groupm["pco_id"])
  g = Group.where(:pco_group_id => groupm["group_id_pco"])
  if p.count > 0 and g.count > 0
    input = GroupMembership.create(
    :group_id           => g[0].id,
    :person_id          => p[0].id,
    :leader             => groupm['leader'],
    :started            => groupm['started'],
    :ended              => groupm['ended']
      )
  end
puts "Processing Member: #{groupm['person_id']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
