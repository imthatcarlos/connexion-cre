class JobOrder < ApplicationRecord
  self.table_name = "job_order"

  has_one :change_item, foreign_key: :order_fk, class_name: "JobChangeItem"
end

# == Schema Information
#
# Table name: job_order
#
#  id               :integer          not null, primary key
#  vendor_name      :string(255)
#  ship_via         :string(255)
#  internal_notes   :text
#  vendor_id        :integer
#  hold_id          :string(255)
#  total_cost       :decimal(19, 2)
#  shipping_notes   :text
#  transaction_date :date
#  transaction_time :time
#  total_sell       :decimal(19, 2)
#  freight_terms    :string(255)
#  bom_id           :integer
#  source           :integer
#  ship_date        :date
#  reserve_date     :date
#  po_num           :string(255)
#  address_id       :integer
#  vendorquote_id   :integer
#  document_fk      :string(255)
#  original_po      :boolean          not null
#  batch_id         :string(255)
#  external_date    :date
#
# Indexes
#
#  job_order_bom_id_index  (bom_id)
#
# Foreign Keys
#
#  fk5789044c36056b6   (vendorquote_id => job_vendor.id)
#  fk5789044c7dab9cd6  (address_id => job_address.id)
#  fk5789044c88edfc14  (document_fk => job_document_log.document_name)
#  fk5789044c895b1b5f  (bom_id => job_bom.id) ON DELETE => cascade
#
