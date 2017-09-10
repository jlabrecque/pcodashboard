class CreateCampus < ActiveRecord::Migration[5.0]

def self.up
  create_table :campus do |t|
    t.string "campus_id_pco"
    t.string "campus_name"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.timestamps
  end
  main = Campu.create(
    :campus_id       => "000000",
    :campus_name     =>  "Main Campus",
    :street          => "",
    :city            => "",
    :state           => "",
    :zip             => ""
  )
end
def self.down
  drop_table :campus
  end
end
