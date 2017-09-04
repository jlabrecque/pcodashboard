class CreateCampaignMeta < ActiveRecord::Migration[5.0]
def self.up
  create_table :campaign_meta do |t|
    t.string :campaign_id
    t.text   :campaign_name
    t.float  :totalpledged
    t.float  :totalprogress
    t.float  :percentprogress
    t.integer :num_pledges
    t.timestamps
  end
end
  def self.down
    drop_table :campaign_meta
  end
end
