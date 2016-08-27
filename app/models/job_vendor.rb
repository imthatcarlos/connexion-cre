class JobVendor < ApplicationRecord
  self.table_name = "job_vendor"
end

# == Schema Information
#
# Table name: job_vendor
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  job_id            :integer
#  actor_id          :integer
#  vendor_short_name :string(255)
#  frieght_terms     :string(255)
#  rep               :boolean
#  next_po           :string(255)
#  ship_from_br      :string(255)
#  shipping_instr    :text
#  ship_via          :string(255)
#  ship_from         :integer
#  address_fk        :integer
#  shipaddress_fk    :integer
#  quote_number      :string(255)
#  payment_terms     :string(255)
#  vendor_type       :integer
#
# Indexes
#
#  job_vendor_address_fk_index      (address_fk)
#  job_vendor_job_id_index          (job_id)
#  job_vendor_shipaddress_fk_index  (shipaddress_fk)
#
# Foreign Keys
#
#  fka4d6c80a2572dbbc  (shipaddress_fk => job_address.id)
#  fka4d6c80a7dab9c80  (address_fk => job_address.id) ON DELETE => cascade
#  fka4d6c80ad6b513aa  (job_id => job_project.id)
#
