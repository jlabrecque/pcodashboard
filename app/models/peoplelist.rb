class Peoplelist < ApplicationRecord
  has_many :peoplelist_people
  has_many :members, :through =>  :peoplelist_people, :source => :person
  scope :byupdate, lambda { order("list_updated_pco ASC") }
  has_many :focallists
  has_many :rsvp_events
end
