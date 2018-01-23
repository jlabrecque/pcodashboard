class CreateHgifts < ActiveRecord::Migration[5.0]
    def self.up
    create_table :hgifts do |t|
    t.string  "pco_id"
    t.integer "person_id"
    t.string  "last_name"
    t.string  "first_name"
    t.string  "campus"
    t.string  "family"
    t.text    "month1"
    t.float   "month1gift"
    t.text    "month2"
    t.float   "month2gift"
    t.text    "month3"
    t.float   "month3gift"
    t.text    "month4"
    t.float   "month4gift"
    t.text    "month5"
    t.float   "month5gift"
    t.text    "month6"
    t.float   "month6gift"
    t.text    "month7"
    t.float   "month7gift"
    t.text    "month8"
    t.float   "month8gift"
    t.text    "month9"
    t.float   "month9gift"
    t.text    "month10"
    t.float   "month10gift"
    t.text    "month11"
    t.float   "month11gift"
    t.text    "month12"
    t.float   "month12gift"
    t.float   'annavg'
    t.float   'lastqtravg'
    t.float   'lastmntavg'
    t.timestamps
  end
end

  def self.down
    drop_table :hgifts
  end
end
