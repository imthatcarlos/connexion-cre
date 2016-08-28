class JobQuote < ApplicationRecord
  self.table_name = "job_quote"

  has_one :fixture, foreign_key: :customer_item_fk, class_name: "JobFixture"
end
