class JobRelease < ApplicationRecord
  self.table_name = "job_release"
end

# == Schema Information
#
# Table name: job_release
#
#  id               :integer          not null, primary key
#  vendor_name      :string(255)
#  ship_via         :string(255)
#  internal_notes   :text
#  vendor_id        :integer
#  transaction_id   :string(255)
#  total_cost       :decimal(19, 2)
#  shipping_notes   :text
#  transaction_date :date
#  transaction_time :time
#  total_sell       :decimal(19, 2)
#  freight_terms    :string(255)
#  bom_id           :integer
#  external_date    :date
#  release_number   :string(255)
#  internal_date    :date
#  truck_number     :string(255)
#  document_fk      :string(255)
#  address_id       :integer
#  batch_id         :string(255)
#
# Indexes
#
#  job_release_bom_id_index  (bom_id)
#
# Foreign Keys
#
#  fk224d5d857dab9cd6  (address_id => job_address.id)
#
