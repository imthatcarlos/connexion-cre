class JobFeeChange < ApplicationRecord
  self.table_name = "job_fee_change"
  belongs_to :bom, foreign_key: :bom_id, class_name: "JobBom"
  belongs_to :customer_change, foreign_key: :custoemrchange_id, class_name: "JobCustChange"
  belongs_to :fee, foreign_key: :fee_id, class_name: "JobFee"
end

# == Schema Information
#
# Table name: job_fee_change
#
#  id                :integer          not null, primary key
#  rep_id            :integer
#  fee_change        :decimal(19, 2)
#  status            :integer
#  name              :string(255)
#  purchase_order    :string(255)
#  bom_id            :integer
#  transaction_date  :date
#  transaction_time  :time
#  customerchange_id :integer
#  fee_id            :integer
#  processing_status :integer
#
# Foreign Keys
#
#  fk43e5944bd1633c4a  (customerchange_id => job_cust_change.id)
#  fk43e5944bf65080fa  (fee_id => job_fees.id)
#
