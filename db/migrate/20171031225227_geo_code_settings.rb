class GeoCodeSettings < ActiveRecord::Migration[5.0]
  def self.up
    add_column(:settings, :namecheck_words, :string)
  end
  def self.down
    remove_column(:settings, :namecheck_words)
  end
end
