class JobChange < ApplicationRecord
  self.table_name = "job_change"

  belongs_to :component, foreign_key: :transaction_id, primary_key: :order_number, class_name: "JobComponent"
end

# == Schema Information
#
# Table name: job_change
#
#  id                :integer          not null, primary key
#  vendor_name       :string(255)
#  ship_via          :string(255)
#  internal_notes    :text
#  vendor_id         :integer
#  transaction_id    :string(255)
#  total_cost        :decimal(19, 2)
#  shipping_notes    :text
#  transaction_date  :date
#  transaction_time  :time
#  total_sell        :decimal(19, 2)
#  freight_terms     :string(255)
#  bom_id            :integer
#  status            :integer
#  original_po       :boolean
#  pending_count     :integer
#  address_id        :integer
#  document_fk       :string(255)
#  customer_fk       :integer
#  releasematerial   :boolean
#  processing_status :integer
#  batch_id          :string(255)
#  external_date     :date
#
# Indexes
#
#  job_change_customer_fk_index  (customer_fk)
#
# Foreign Keys
#
#  fk848f3672d938bf24  (customer_fk => job_cust_change.id)
#
