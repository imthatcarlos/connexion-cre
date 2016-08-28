class JobTotal < ApplicationRecord
  has_one :fixture, foreign_key: :total_id, class_name: "JobFixture"
  has_one :component, foreign_key: :total_id, class_name: "JobComponent"
end
