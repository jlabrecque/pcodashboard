require 'rubygems'
require 'pcocore_api.rb'
require 'date'


people_geo_created = 0
people_geo_updated = 0
campus_geo_created = 0
campus_geo_updated = 0
#Add per person georecords


dow = Date.today.strftime("%A")

case dow
  when "Monday"
#    regex = "^[a-fA-F]" # get last_names starting with A-F
        regex = "^[w-zW-Z]" # get last_names starting with A-F
  when "Tuesday"
    regex = "^[g-lG-L]" # get last_names starting with A-F
  when "Wednesday"
    regex = "^[m-rM-R]" # get last_names starting with A-F
  when "Thursday"
    regex = "^[s-vS-V]" # get last_names starting with A-F
  when "Friday"
    regex = "^[w-zW-Z]" # get last_names starting with A-F
else
    regex = ""
end

puts "#{dow}, #{regex}"

Person.where("last_name REGEXP ?", regex).each do |person|
  puts "PCO_id: #{person.pco_id}, Name: #{person.last_name}, #{person.first_name}"
    address,long,lat = geocode_people(person.pco_id,person.street,person.city,person.state,person.zip)
    geoexists = GeoMap.where(:pco_id => person.pco_id)
    if !address.blank?
      if !geoexists.exists? #create new record

            georecord = GeoMap.create(
            :person_id      =>    person.id,
            :pco_id         =>    person.pco_id,
            :campus_id      =>    "na",
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          puts "*** Creating new Georecord #{person.pco_id} #{address} ***"
          people_geo_created += 1
      else
            georecord = GeoMap.update(geoexists[0].id,
            :person_id      =>    person.id,
            :pco_id         =>    person.pco_id,
            :campus_id      =>    "na",
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          puts "*** Updating Georecord  #{person.pco_id} #{address} ***"
          people_geo_updated += 1
      end
  end
end
#Add per Campus georecords
Campu.all.each do |campus|
    address,long,lat = geocode_people(campus.campus_id_pco,campus.street,campus.city,campus.state,campus.zip)
    geoexists = GeoMap.where(:campus_id => campus.campus_id_pco)
    if !address.blank?
      if !geoexists.exists? #create new record

            georecord = GeoMap.create(
            :person_id      =>    0,
            :pco_id         =>    "na",
            :campus_id      =>    campus.campus_id_pco,
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          puts "*** Creating new Georecord #{campus.campus_id_pco} #{address} ***"
          campus_geo_created += 1
      else
            georecord = GeoMap.update(geoexists[0].id,
            :person_id      =>    0,
            :pco_id         =>    "na",
            :campus_id      =>    campus.campus_id_pco,
            :full_address   =>    address,
            :latitude       =>    lat,
            :longitude      =>    long
            )
          puts "*** Updating Georecord  #{campus.campus_id_pco} #{address} ***"
          campus_geo_updated += 1
      end
  end
end
puts "***************************************"
puts "All people and campus records processed"
puts ""
puts "#{people_geo_created} people geo records created"
puts "#{people_geo_updated} people geo records updated"
puts "#{campus_geo_created} campus geo records created"
puts "#{campus_geo_updated} campus geo records updated"
puts "***************************************"
