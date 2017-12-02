class PersonAddLastServed < ActiveRecord::Migration[5.0]
  def self.up
    add_column(:people, :first_served, :string)
    add_column(:people, :last_served, :string)
  end
  def self.down
    remove_column(:people, :last_served)
    remove_column(:people, :first_served)
  end
end
