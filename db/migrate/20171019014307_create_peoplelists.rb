class CreatePeoplelists < ActiveRecord::Migration[5.0]
def self.up
    create_table :peoplelists do |t|
      t.string  "list_id_pco"
      t.string  "name"
      t.text    "description"
      t.boolean "focallist"
      t.string  "status"
      t.string "list_updated_pco"
      t.timestamps
    end
  end

  def self.down
    drop_table :peoplelists
    end
end
