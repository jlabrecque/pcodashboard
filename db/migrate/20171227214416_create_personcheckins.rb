class CreatePersoncheckins < ActiveRecord::Migration[5.0]
    def self.up
    create_table :personcheckins do |t|
      t.integer "person_id"
      t.string "pco_id"
      t.string "fullname"
      t.string "week1"
      t.string "week1value"
      t.string "week2"
      t.string "week2value"
      t.string "week3"
      t.string "week3value"
      t.string "week4"
      t.string "week4value"
      t.string "week5"
      t.string "week5value"
      t.string "week6"
      t.string "week6value"
      t.string "week7"
      t.string "week7value"
      t.string "week8"
      t.string "week8value"
      t.string "week9"
      t.string "week9value"
      t.string "week10"
      t.string "week10value"
      t.string "week11"
      t.string "week11value"
      t.string "week12"
      t.string "week12value"
      t.string "week13"
      t.string "week13value"
      t.string "week14"
      t.string "week14value"
      t.string "week15"
      t.string "week15value"
      t.string "week16"
      t.string "week16value"
      t.string "week17"
      t.string "week17value"
      t.string "week18"
      t.string "week18value"

      t.timestamps
    end
  end
  def self.down
    drop_table :personcheckins
    end

end
