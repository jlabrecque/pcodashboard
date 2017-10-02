class HouseholdPerson < ApplicationRecord
  belongs_to :person
  belongs_to :household
end
