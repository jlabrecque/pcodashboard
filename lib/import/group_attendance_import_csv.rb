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

  input = GroupAttendance.create(
  :group_id           => groupa['group_id'],
  :person_id          => groupa['person_id'],
  :attend_date        => groupa['attend_date']
  )

puts "Processing Attendance: #{groupa['person_id']}"
totcreated += 1
end

puts "** ALl records processed -- CSV file complete **"
puts "#{totcreated} group records processed"
