class JobCustomer < ApplicationRecord
  self.table_name = "job_customer"

  belongs_to :projects, foreign_key: :job_id, class_name: "JobProject"
  belongs_to :address, foreign_key: :address_fk, class_name: "JobAddress"
  belongs_to :main_contact, foreign_key: :main_contact_fk, class_name: "JobContact"
  belongs_to :shipping_address, foreign_key: :shipaddress_fk, class_name: "JobAddress"
  belongs_to :alt_address, foreign_key: :altaddress_fk, class_name: "JobAddress"
end

# ECLIPSE
# actor_id = Eclipse Customer ID
# ship_to = Eclipse Customer ID of Ship To Customer
# shipping_instr = Eclipse default Shipping Instructions for Customer
# credit_br = Eclipse Bill-To Branch Customer Default
# sales_source = Eclipse Default Sales Source for accounting
# ship_from_br = Eclipse Ship From Branch Default
# inside_sales = Eclipse Customer Inside Salesperson
# outside_sales = Eclipse Customer Outside Salesman
# freight_in_exempt = Freight In Exempt setting from Eclipse
# dflt_vfrt_terms = Eclipse Default Vendor Freight Terms
# dflt_cfrt_terms = Eclipse Default Customer Freight Terms
# tax_exempt_number = Eclipse Tax Exempt Number

# MISC
# id = system assigned id number and key to table
# override_address = if user overrides address on info summary screen
# address_fk = pointer to job_address for all of the address information
# main_contact_fk = pointer to job_contact table to get contact information
# shipaddress_fk = pointer to job_address for the shipping address.
# awarded_date = Date the Customer was awarded the job
# altaddress_fk = Alternate address information

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
