class JobCost < ApplicationRecord
  self.table_name = "job_cost"
  self.primary_key = :id

  has_one :fixture, foreign_key: :vendor_item_fk, class_name: "JobFixture"
  has_one :component, foreign_key: :vendor_item_fk, class_name: "JobComponent"

  belongs_to :vendor, foreign_key: :vendor_id, primary_key: :actor_id, class_name: "JobVendor"
end