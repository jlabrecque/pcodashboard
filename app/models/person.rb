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
  # # Enumerize
   extend Enumerize
   enumerize :week1checkin, in: [:R, :V, :N], default: :N
   enumerize :week2checkin, in: [:R, :V, :N], default: :N
   enumerize :week3checkin, in: [:R, :V, :N], default: :N
   enumerize :week4checkin, in: [:R, :V, :N], default: :N
   enumerize :week5checkin, in: [:R, :V, :N], default: :N
   enumerize :week6checkin, in: [:R, :V, :N], default: :N
   enumerize :week7checkin, in: [:R, :V, :N], default: :N
   enumerize :week8checkin, in: [:R, :V, :N], default: :N
   enumerize :week9checkin, in: [:R, :V, :N], default: :N
   enumerize :week10checkin, in: [:R, :V, :N], default: :N
   enumerize :week11checkin, in: [:R, :V, :N], default: :N
   enumerize :week12checkin, in: [:R, :V, :N], default: :N
   enumerize :week13checkin, in: [:R, :V, :N], default: :N
   enumerize :week14checkin, in: [:R, :V, :N], default: :N
   enumerize :week15checkin, in: [:R, :V, :N], default: :N
   enumerize :week16checkin, in: [:R, :V, :N], default: :N
   enumerize :week17checkin, in: [:R, :V, :N], default: :N
   enumerize :week18checkin, in: [:R, :V, :N], default: :N
   enumerize :week1gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week2gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week3gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week4gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week5gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week6gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week7gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week8gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week9gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week10gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week11gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week12gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week13gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week14gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week15gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week16gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week17gift, in: [:D, :K, :M, :N], default: :N
   enumerize :week18gift, in: [:D, :K, :M, :N], default: :N

  #
  #  # Rails Enum
   enum status: { active: 0, archived: 1 }

    def self.search(search)
      where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
    end

end
