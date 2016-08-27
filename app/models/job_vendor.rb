class JobVendor < ApplicationRecord
  self.table_name = "job_vendor"

  belongs_to :address, foreign_key: :address_fk, class_name: "JobAddress"
  belongs_to :ship_address, foreign_key: :shipaddress_fk, class_name: "JobAddress"
  belongs_to :project, foreign_key: :job_id, class_name: "JobProject"
end

# ECLIPSE
# actor_id = Eclipse Vendor ID
# freight_terms = Eclipse default Freight Terms
# vendor_short_name = Eclipse Vendor Short Name
# shipping_instr = Eclipse Default Shipping Instruction for Vendor
# ship_via = Eclipse Default Ship Via
# ship_from_br = Eclipse Ship From Branch Default
# ship_from = Eclipse Ship From Vendor for this Pay To Vendor
# payment_terms = Eclipse Vendor Payment Terms

# MISC
# id = system assigned id number and key to table
# rep = will be vendor id of rep, and is only set if the vendor is associated with the rep on the
# Job Management Maintenance Screen.
# next_po = internal Job Management number use to determine the next sequential PO
# Number.
# address_fk = key to address table for the address of this vendor
# shipaddress_fk = key to address table for the ship to vendor
# vendor_type = type of vendor as set up in the Job Management maintenance screen.

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
