class JobComponent < ApplicationRecord
  self.table_name = "job_component"
  self.primary_key = "fixture_id"

  has_many :job_changes, foreign_key: :transaction_id, primary_key: :order_number, class_name: "JobChange"

  belongs_to :total, foreign_key: :total_id, class_name: "JobTotal"
  belongs_to :quote, foreign_key: :customer_item_fk, class_name: "JobQuote"
  belongs_to :cost, foreign_key: :vendor_item_fk, class_name: "JobCost"
  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end

# == Schema Information
#
# Table name: job_component
#
#  fixture_id            :integer          not null, primary key
#  description           :string(255)
#  quantity              :integer          not null
#  stock_pn              :string           not null
#  matrix_cell           :string(255)
#  create_stamp          :datetime         not null
#  uom                   :string(255)
#  submittal_status      :string(255)
#  has_notes             :boolean
#  addl_desc             :string(255)
#  customer_item_fk      :integer
#  total_id              :integer
#  vendor_item_fk        :integer
#  fixture_fk            :integer
#  update_stamp          :date
#  qty_uom               :string(255)
#  um_qty                :integer
#  pricing_uom           :string(255)
#  price_per_qty         :integer
#  ns_stock              :boolean
#  order_number          :string(255)
#  classification        :string(255)
#  prod_cat              :string(255)
#  prod_line             :string(255)
#  draft_item            :boolean          not null
#  vendor_pricing_vendor :integer          not null
#  customer_po           :string(255)
#
# Indexes
#
#  job_component_customer_item_fk_index  (customer_item_fk)
#  job_component_fixture_fk_index        (fixture_fk)
#  job_component_vendor_item_fk_index    (vendor_item_fk)
#
# Foreign Keys
#
#  fk6ba3eafb700f8171  (total_id => job_totals.id)
#  fk6ba3eafb724bd8e4  (fixture_fk => job_fixture.fixture_id)
#  fk6ba3eafb937633a1  (customer_item_fk => job_quote.id)
#  fk6ba3eafbf51528e1  (vendor_item_fk => job_cost.id)
#
