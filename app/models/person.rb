class Person < ApplicationRecord
  has_many :mccampaignsends
  has_many :mccampaigns, :through => :mccampaignsends
  has_many :group_memberships
  has_many :ingroups, :through => :group_memberships, :source => :group
  has_many :group_attendances
  has_many :attended, :through =>  :group_attendances, :source => :group
  has_many :household_people
  has_many :family, :through =>  :household_people, :source => :household
  has_many :peoplelist_people
  has_many :lists, :through =>  :peoplelist_people, :source => :peoplelist
  has_many :teammembers
  has_many :mailchimplists
  has_many :workflowcards
  has_many :check_ins
  has_many :donations
  has_many :geo_maps
  has_many :pledges
  has_one :campu

  serialize :email_array
  scope :active, lambda { where(:people_status => "active")}
  scope :inactive, lambda { where(:people_status => "inactive")}
  scope :sorted, lambda { order("pco_id ASC") }
  scope :newest_first, lambda { order("created_at DESC") }
  scope :campbell, -> { where(:campus => "Campbell")}
  scope :gilroy, -> { where(:campus => "Gilroy")}
  scope :morganhill, -> { where(:campus => "Morgan Hill")}
  scope :sanjose, -> { where(:campus => "San Jose")}
  scope :member, -> { where(:membership => "Member")}

  # scope :focallist, -> { joins(:lists).where("peoplelists.focallist = ?",TRUE) }




    def self.search(search)
      where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
    end

end
