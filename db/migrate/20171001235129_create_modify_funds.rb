class CreateModifyFunds < ActiveRecord::Migration[5.0]
  def self.up
    add_column(:funds, :tithe, :boolean, :default => 1)
  end
  def self.down
    remove_column(:funds, :tithe)
  end
end
