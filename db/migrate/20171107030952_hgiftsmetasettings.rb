class Hgiftsmetasettings < ActiveRecord::Migration[5.0]
  def self.up
    add_column(:settings, :hgiftday, :string, :default => "Sun")
    prime = Metum.create(:modeltype => "hgift", :last_id_imported => "", :last_offset => "0", :total_processed => 0, :total_created => 0, :total_updated => 0, :last_import => ("2010-01-01").to_date)

  end
  def self.down
    remove_column(:settings, :hgiftday)
  end

end
