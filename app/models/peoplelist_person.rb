class PeoplelistPerson < ApplicationRecord
  belongs_to :peoplelist
  belongs_to :person
end
