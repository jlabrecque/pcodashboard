class Group < ApplicationRecord
  has_many :group_memberships
  has_many :members, :through =>  :group_memberships, :source => :person
  has_many :group_attendances
  has_many :attendees, :through =>  :group_attendances, :source => :person
end
