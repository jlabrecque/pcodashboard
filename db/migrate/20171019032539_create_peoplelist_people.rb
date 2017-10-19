class CreatePeoplelistPeople < ActiveRecord::Migration[5.0]
  def self.up
      create_table :peoplelist_people do |t|
        t.integer  "peoplelist_id"
        t.integer  "person_id"
        t.timestamps
      end
    end

    def self.down
      drop_table :peoplelist_people
      end
end
