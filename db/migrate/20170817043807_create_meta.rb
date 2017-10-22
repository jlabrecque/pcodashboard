class CreateMeta < ActiveRecord::Migration[5.0]
    def self.up
    create_table :meta do |t|
      t.string  "modeltype"
      t.date    "last_import"
      t.string  "last_id_imported"
      t.integer "total_processed"
      t.integer "total_created"
      t.integer "total_updated"
      t.integer  "last_offset"
      t.timestamps
    end
   prime = Metum.create(:modeltype => "people", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "donations", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "checkins", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "campaigns", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "mccampaigns", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "mclists", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0)
   prime = Metum.create(:modeltype => "plans", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0, :last_import => ("2010-01-01").to_date)

  end
  def self.down
    drop_table :meta
    end

end
