class JobChange < ApplicationRecord
  self.table_name = "job_change"

  # belongs_to :component, foreign_key: :order_number, primary_key: :transaction_id, class_name: "JobComponent"
end