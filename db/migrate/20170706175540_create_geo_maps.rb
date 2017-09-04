class CreateGeoMaps < ActiveRecord::Migration[5.0]
    def self.up
        create_table :geo_maps do |t|
          t.string "pco_id"
          t.string "campus_id"
          t.integer "person_id"
          t.string "full_address"
          t.float "latitude"
          t.float "longitude"
          t.timestamps
        end
        add_index("geo_maps", "person_id")
    end
    def self.down
        drop_table :geo_maps
        end
    end
