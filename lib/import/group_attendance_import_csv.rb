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
  if p.count > 0
    input = GroupAttendance.create(
    :group_id           => groupa['group_id'],
    :person_id          => p[0].id,
    :attend_date        => groupa['attend_date']
    )
  end

puts "Processing Attendance: #{groupa['person_id']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
