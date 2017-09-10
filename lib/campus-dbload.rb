require 'rubygems'
require 'pp'
require 'date'
require 'json'
require 'pcocore_api.rb'


total_created = 0
total_updated = 0



if !campus_fd().empty? #Multicampus configured Field Def
      field_options = campus_load()
      field_options["data"].each do |fo|
      campusexists = Campu.where(:campus_id_pco => fo["id"] )
        if campusexists.empty? #create
            puts "Creating Campus: #{fo["attributes"]["value"]}"
            Campu.create(
            :campus_id_pco    =>  fo["id"],
            :campus_name  =>  fo["attributes"]["value"]
            )
            total_created += 1
        else #update
            puts "Updating Campus: #{fo["attributes"]["value"]}"
            Campu.update(campusexists[0]["id"],
            :campus_id_pco    =>  fo["id"],
            :campus_name  =>  fo["attributes"]["value"]
            )
            total_updated += 1
        end
      end
      #remove default Main Campus
      xcampus = Campu.where(:campus_id_pco => "000000")
      if xcampus.count > 0
        puts "Removing default campus"
        xcampus[0].delete
      end
end
      puts "Total Created: #{total_created}"
      puts "Total Updated: #{total_updated}"
