class Household < ApplicationRecord
  has_many :household_people
  has_many :members, :through =>  :household_people, :source => :person
end
