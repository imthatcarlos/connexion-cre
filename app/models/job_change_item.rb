class JobChangeItem < ApplicationRecord
  self.table_name = "job_change_item"

  belongs_to :job_order, foreign_key: :order_fk, class_name: "JobOrder"
  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end
