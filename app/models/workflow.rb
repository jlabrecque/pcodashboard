class Workflow < ApplicationRecord
  has_many :workflowsteps
  has_many :workflowcards
end
