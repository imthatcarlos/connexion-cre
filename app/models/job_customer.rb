class JobCustomer < ApplicationRecord
  self.table_name = "job_customer"

  has_many :projects, foreign_key: :job_id, class_name: "JobProject"
  has_one :address, foreign_key: :address_fk, class_name: "JobAddress"
end

# == Schema Information
#
# Table name: job_customer
#
#  id                    :integer          not null, primary key
#  name                  :string(255)      not null
#  job_id                :integer
#  actor_id              :integer
#  inside_sales          :string(255)
#  outside_sales         :string(255)
#  sales_source          :string(255)
#  credit_br             :string(255)
#  ship_to               :string
#  customer_po           :string(255)
#  dflt_cfrt_terms       :string(255)
#  dflt_vfrt_terms       :string(255)
#  freight_in_exempt     :boolean
#  ship_from_br          :string(255)
#  ship_via_cust         :string(255)
#  ship_via_vend         :string(255)
#  shipping_instr        :text
#  override_address      :boolean
#  shipaddress_fk        :integer
#  address_fk            :integer
#  main_contact_fk       :integer
#  awarded_date          :date
#  use_alternate_address :boolean
#  altaddress_fk         :integer
#  ship_via_cust_direct  :string(255)
#  alt_contact_fk        :integer
#  shipto_index          :string(255)
#  tax_code              :string(255)
#
# Indexes
#
#  job_customer_address_fk_index      (address_fk)
#  job_customer_altaddress_fk_index   (altaddress_fk)
#  job_customer_inside_sales          (inside_sales)
#  job_customer_job_id                (job_id)
#  job_customer_outside_sales         (outside_sales)
#  job_customer_shipaddress_fk_index  (shipaddress_fk)
#
# Foreign Keys
#
#  fk6c5bfa202572dbbc  (shipaddress_fk => job_address.id) ON DELETE => cascade
#  fk6c5bfa207dab9c80  (address_fk => job_address.id) ON DELETE => cascade
#  fk6c5bfa2093e3d6e9  (altaddress_fk => job_address.id)
#  fk6c5bfa20a4e00556  (alt_contact_fk => job_contact.id) ON DELETE => cascade
#  fk6c5bfa20d6b513aa  (job_id => job_project.id)
#  fk6c5bfa20ed994f46  (main_contact_fk => job_contact.id) ON DELETE => cascade
#
