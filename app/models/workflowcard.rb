class Workflowcard < ApplicationRecord
  belongs_to :workflow
  belongs_to :person
  has_many :workflowcardnotes
end
