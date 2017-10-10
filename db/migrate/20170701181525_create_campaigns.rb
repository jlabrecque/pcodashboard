class CreateCampaigns < ActiveRecord::Migration[5.0]
  def self.up
  create_table :campaigns do |t|
    t.string "campaign_id"
    t.string "campaign_name"
    t.string "start_date"
    t.string "end_date"
    t.string "fund_id_pco"
    t.integer "fund_id"
    t.boolean "closed", :null => false, :default => FALSE
    t.datetime "closeddate"
    t.integer "num_pledges", :default => 0
    t.integer "num_donations", :default => 0.00
    t.float "totalcommitted", :default => 0.00
    t.float "qtrcommited", :default => 0.00
    t.float "avgpledge", :default => 0.00
    t.float "totalprogress", :default => 0.00
    t.float "qtrprogress", :default => 0.00
    t.timestamps
  end
  add_index("campaigns", "fund_id")
  user1 = Campaign.create(
    :campaign_id        =>  "0",
    :campaign_name      =>  "Dummy Seed Campaign",
    :start_date         =>  "1/1/2017",
    :end_date           =>  "1/1/2017",
    :fund_id            =>  "1",
    :closed             =>  1
  )

end
def self.down
  drop_table :campaigns
  end
end
