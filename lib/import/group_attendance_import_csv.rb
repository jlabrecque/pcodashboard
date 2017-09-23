require 'rubygems'
require 'json'
require 'pp'
require 'csv'

csvfile = "lib/archive/dummy_group_attendance.csv"

totcreated = 0
puts "Starting processing..."
puts "Opening CSV file for read..."

CSV.foreach(csvfile, headers: true) do |row|
  groupa = row.to_hash
  p = Person.where(:pco_id => groupa["pco_id"])
  g = Group.where(:pco_group_id => groupa["group_id_pco"])
  if p.count > 0 and g.count > 0
    input = GroupAttendance.create(
    :group_id           => g[0].id,
    :person_id          => p[0].id,
    :attend_date        => groupa['attend_date']
    )
    puts "Processing Attendance: #{p[0].id}"
  end
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
