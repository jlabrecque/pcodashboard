class Donation < ApplicationRecord
  scope :sorted, lambda { order("donation_id ASC") }
  #scope :search, lambda { |query| where(["donation_id LIKE ?", "%#{query}%"]) }
end
