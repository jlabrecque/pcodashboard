class Eventtime < ApplicationRecord
  belongs_to :event
  has_many :checkins
end
