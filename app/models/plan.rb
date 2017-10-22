class Plan < ApplicationRecord
  belongs_to :service_type
  scope :byupdate, lambda { order("pl_updated_at ASC") }
end
