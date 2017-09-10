class CreatePeople < ActiveRecord::Migration[5.0]
  def self.up
    create_table :people do |t|
      t.string "pco_id"
      t.string "first_name"
      t.string "last_name"
      t.string "middle_name"
      t.string "nickname"
      t.string "fullname"
      t.string "email"
      t.string "hphone"
      t.string "mphone"
      t.string "carrier"
      t.string "gender"
      t.string "birthdate"
      t.string "campus"
      t.integer "campus_id"
      t.string "membership"
      t.string "street"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "peopleapp_link"
      t.string "people_thumbnail"
      t.string "people_notes"
      t.string "people_status"
      t.string "pco_created_at"
      t.string "pco_updated_at"
      t.string "first_attended"
      t.string "last_attended"
      t.string "first_donation"
      t.string "last_donation"
      t.string "email_array"
      t.timestamps
    end
  end
  def self.down
    drop_table :people
    end
  end
