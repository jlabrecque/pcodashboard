class CheckIn < ApplicationRecord
  belongs_to :eventtime
  belongs_to :person

  scope :bydate, lambda { order("checkin_time ASC") }
end
