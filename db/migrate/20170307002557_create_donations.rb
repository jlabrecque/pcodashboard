class CreateDonations < ActiveRecord::Migration[5.0]
def self.up
  create_table :donations do |t|
    t.string "donation_id"
    t.integer "person_id"
    t.decimal "amount_cents"
    t.string "donation_created_at"
    t.string "donation_updated_at"
    t.string "payment_channel"
    t.string "payment_method"
    t.string "payment_method_sub"
    t.string "designation_id"
    t.decimal "designation_cents"
    t.string "fund_id_pco"
    t.string "pco_id"
    t.integer "fund_id"
    t.timestamps
  end
  add_index("donations", "fund_id")
end
def self.down
  drop_table :donations
  end
end
