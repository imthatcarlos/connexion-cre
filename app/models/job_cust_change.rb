class JobCustChange < ApplicationRecord
  self.table_name = "job_cust_change"

  belongs_to :bom, foreign_key: :bom_id, class_name: "JobBom"
end

# == Schema Information
#
# Table name: job_cust_change
#
#  id                :integer          not null, primary key
#  status            :integer
#  customer_id       :integer
#  internal_notes    :text
#  change_number     :string(255)
#  reason_for_change :text
#  total_cost        :decimal(19, 2)
#  follow_up_date    :datetime
#  transaction_date  :date
#  transaction_time  :time
#  po_number         :string(255)
#  total_sell        :decimal(19, 2)
#  bom_id            :integer
#  approval_notes    :text
#  approved_by       :string(255)
#  initiated_by      :string(255)
#  supress_customer  :boolean
#  supress_vendor    :boolean
#  created_by        :string(255)
#  new_customer_po   :boolean
#  internal_change   :boolean
#  document_fk       :string(255)
#  processing_status :integer
#  freight_in_exempt :boolean
#
