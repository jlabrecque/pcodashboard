class Pledge < ApplicationRecord
  scope :sorted, lambda { order("pco_id ASC") }
  #scope :search, lambda { |query| where(["pco_id LIKE ?", "%#{query}%"]) }
end
