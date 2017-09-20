class AddChkDonMarkers < ActiveRecord::Migration[5.0]

  def self.up
    add_column(:people, :first_checkin, :string)
    add_column(:people, :last_checkin, :string)
  end
  def self.down
    remove_column(:people, :first_checkin)
    remove_column(:people, :last_checkin)
  end
end
