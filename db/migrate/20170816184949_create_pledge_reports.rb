class CreatePledgeReports < ActiveRecord::Migration[5.0]
  def self.up
    create_table :pledge_reports do |t|
      t.string  :quarter
      t.string  :year
      t.integer :campaign_id
      t.string  :reportname
      t.string  :filename
      t.timestamps
    end
  end
    def self.down
      drop_table :pledge_reports
    end


end
