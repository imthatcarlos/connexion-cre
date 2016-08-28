class JobChange < ApplicationRecord
  self.table_name = "job_change"

  belongs_to :component, foreign_key: :transaction_id, primary_key: :order_number, class_name: "JobComponent"
end
