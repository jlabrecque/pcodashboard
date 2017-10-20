class Mccampaign < ApplicationRecord
  has_many :mccampaignsends

  scope :bysend, lambda { order("send_time ASC") }
end
