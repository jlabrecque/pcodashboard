class Pledge < ApplicationRecord
  scope :sorted, lambda { order("pco_id ASC") }
  #scope :search, lambda { |query| where(["pco_id LIKE ?", "%#{query}%"]) }
  belongs_to :campaign
  belongs_to :person
  belongs_to :household
end
