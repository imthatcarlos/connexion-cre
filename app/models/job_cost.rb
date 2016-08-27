class JobCost < ApplicationRecord
  self.table_name = "job_cost"

  has_one :fixture, foreign_key: :vendor_item_fk, class_name: "JobFixture"
end