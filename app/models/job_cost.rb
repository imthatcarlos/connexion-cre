class JobCost < ApplicationRecord
  self.table_name = "job_cost"
  self.primary_key = :id

  has_one :fixture, foreign_key: :vendor_item_fk, class_name: "JobFixture"
  has_one :component, foreign_key: :vendor_item_fk, class_name: "JobComponent"

  belongs_to :vendor, foreign_key: :vendor_id, primary_key: :actor_id, class_name: "JobVendor"
end

# == Schema Information
#
# Table name: job_cost
#
#  id                   :integer          not null, primary key
#  cost                 :decimal(19, 3)   not null
#  formula              :string(255)
#  vendor_id            :integer
#  extended_cost        :decimal(19, 2)
#  received_cost        :decimal(19, 2)   default(0.0), not null
#  returned_cost        :decimal(19, 2)   default(0.0), not null
#  received_return_cost :decimal(19, 2)   default(0.0), not null
#
