class Donation < ApplicationRecord
  scope :sorted, lambda { order("donation_id ASC") }
  scope :tithe, lambda { joins(:fund).where("funds.tithe = 1") }
  scope :giver, lambda { where("count > 0") }
  scope :bydate, lambda { order("donation_created_at ASC") }

  #scope :search, lambda { |query| where(["donation_id LIKE ?", "%#{query}%"]) }
  belongs_to :person
  belongs_to :fund
end
