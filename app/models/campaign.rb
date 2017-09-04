class Campaign < ApplicationRecord

  scope :sorted, lambda { order("campaign_id ASC") }
  scope :newest_first, lambda { order("created_at DESC") }
  #scope :search, lambda { |query| where(["campaign_name LIKE ?", "%#{query}%"]) }


end
