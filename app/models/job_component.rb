class JobComponent < ApplicationRecord
  self.table_name = "job_component"
  self.primary_key = "fixture_id"

  has_many :job_changes, foreign_key: :transaction_id, primary_key: :order_number, class_name: "JobChange"

  belongs_to :total, foreign_key: :total_id, class_name: "JobTotal"
  belongs_to :quote, foreign_key: :customer_item_fk, class_name: "JobQuote"
  belongs_to :cost, foreign_key: :vendor_item_fk, class_name: "JobCost"
  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end
