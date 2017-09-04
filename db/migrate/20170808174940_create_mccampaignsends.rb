class CreateMccampaignsends < ActiveRecord::Migration[5.0]

  def self.up
    create_table :mccampaignsends do |t|
      t.integer :person_id
      t.integer :mccampaign_id
      t.string  :mailchimp_email_id
      t.string  :mailchimp_campaign_id
      t.string  :mailchimp_list_id
      t.string  :email_address
      t.string  :first_name
      t.string  :last_name
      t.string  :status
      t.integer :open_count
      t.string  :last_open
      t.timestamps
    end
    add_index("mccampaignsends", "person_id")
    add_index("mccampaignsends", "mccampaign_id")

  end
    def self.down
      remove_index("mccampaignsends", "mccampaign_id")
      remove_index("mccampaignsends", "person_id")
      drop_table :mccampaignsends
    end

end
