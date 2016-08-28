class JobReturn < ApplicationRecord
  self.table_name = "job_return"
end

# == Schema Information
#
# Table name: job_return
#
#  id                 :integer          not null, primary key
#  vendor_name        :string(255)
#  ship_via           :string(255)
#  internal_notes     :text
#  vendor_id          :integer
#  transaction_id     :string(255)
#  total_cost         :decimal(19, 2)
#  shipping_notes     :text
#  transaction_date   :date
#  transaction_time   :time
#  total_sell         :decimal(19, 2)
#  freight_terms      :string(255)
#  bom_id             :integer
#  reason_return      :string(255)
#  return_oid         :string(255)
#  misc_amount        :decimal(19, 2)
#  address_id         :integer
#  document_fk        :string(255)
#  transaction_type   :integer
#  misc_credit_amount :decimal(19, 2)
#  batch_id           :string(255)
#  external_date      :date
#
