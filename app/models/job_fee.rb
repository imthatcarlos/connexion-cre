class JobFee < ApplicationRecord
  belongs_to :bom, foreign_key: :bom_id, class_name: "JobBom"
end

# == Schema Information
#
# Table name: job_fees
#
#  id               :integer          not null, primary key
#  fee              :decimal(19, 2)
#  transaction_date :date
#  transaction_time :time
#  received_amount  :decimal(19, 2)
#  purchase_order   :string(255)
#  bom_id           :integer
#  fee_change       :decimal(19, 2)
#
