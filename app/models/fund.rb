class Fund < ApplicationRecord
  scope :tithe, lambda { where(:tithe => TRUE)}
end
