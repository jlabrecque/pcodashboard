class CheckIn < ApplicationRecord
  belongs_to :eventtime
  belongs_to :person
end
