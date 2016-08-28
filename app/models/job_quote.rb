class JobQuote < ApplicationRecord
  self.table_name = "job_quote"

  has_one :fixture, foreign_key: :customer_item_fk, class_name: "JobFixture"
end

# == Schema Information
#
# Table name: job_quote
#
#  id                    :integer          not null, primary key
#  price                 :decimal(19, 3)
#  extended_price        :decimal(19, 2)
#  margin                :decimal(19, 6)
#  markup                :decimal(19, 6)
#  returned_price        :decimal(19, 2)
#  received_price        :decimal(19, 2)   default(0.0), not null
#  received_return_price :decimal(19, 2)   default(0.0), not null
#
