class CreateFocallists < ActiveRecord::Migration[5.0]
def self.up
      create_table :focallists do |t|
        t.string  "list_name"
        t.text    "description"
        t.integer "peoplelist_id"
        t.string  "peoplelist_id_pco"
        t.timestamps
      end
    end

    def self.down
      drop_table :focallists
      end

end
