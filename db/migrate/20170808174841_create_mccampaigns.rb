class CreateMccampaigns < ActiveRecord::Migration[5.0]

  def self.up
    create_table :mccampaigns do |t|
      t.string  :mailchimp_campaign_id
      t.integer :mccampaignsend_id
      t.integer :web_id
      t.string  :campaign_type
      t.string  :create_time
      t.string  :send_time
      t.string  :long_archive_url
      t.string  :status
      t.integer :emails_sent
      t.string  :subject_line
      t.string  :title
      t.string  :from
      t.string  :reply_to
      t.integer :opens
      t.integer :unique_opens
      t.float   :open_rate
      t.integer :clicks
      t.float   :click_rate
      t.integer :subscriber_clicks
      t.timestamps
    end
    add_index("mccampaigns", "mccampaignsend_id")
  end
    def self.down
      remove_index("mccampaigns", "mccampaignsend_id")
      drop_table :mccampaigns
    end
end
