require 'rubygems'

if CronoJob.count > 0
    CronoJob.delete_all
    puts "All CronoJob records wiped"
end
