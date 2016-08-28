class JobFixture < ApplicationRecord
  self.table_name = "job_fixture"
  self.primary_key = "fixture_id"

  has_many :change_items, foreign_key: :fixture_fk, class_name: "JobChangeItem"
  has_many :shipments, foreign_key: :fixture_fk, class_name: "JobShipment"
  has_one :component, foreign_key: :fixture_fk, class_name: "JobComponent"

  belongs_to :bom, foreign_key: :bom_fk, class_name: "JobBom"
  belongs_to :cost, foreign_key: :vendor_item_fk, class_name: "JobCost"
  belongs_to :quote, foreign_key: :custom_item_fk, class_name: "JobQuote"
  belongs_to :total, foreign_key: :total_id, class_name: "JobTotal"

  def to_csv
    arr = [
      fixture_type.presence || "N/A",
      vendor_name,
      description,
      quantity,
      nil,
      nil,
      nil,
      nil
    ]
  end

  def vendor_name
    case cost.vendor_id
    when 0
      "N/A"
    when -1
      "STOCK"
    else
      cost.vendor.vendor_short_name
    end
  end
end

# In cases where you need to get detail information about what items have been released and received both in quantity and dollars you have to build some views in Job Management that pulls together both
# fixture and component line item information. Components are sub-component of regular fixture Items. Eclipse created two tables for these items even though they essentially have the same information.
# Because of this the only way I know how to do this is create Fixture Totals View and a Component Totals View and then combine those views in a Summary view.

# == Schema Information
#
# Table name: job_fixture
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
#  fixture_type          :string(255)
#  sort_order            :string(255)
#  vendor_item_fk        :integer
#  customer_item_fk      :integer
#  bom_fk                :integer
#  total_id              :integer
#  update_stamp          :date
#  qty_uom               :string(255)
#  um_qty                :integer
#  pricing_uom           :string(255)
#  price_per_qty         :integer
#  ns_stock              :boolean
#  order_number          :string(255)
#  prod_cat              :string(255)
#  prod_line             :string(255)
#  draft_item            :boolean          not null
#  vendor_pricing_vendor :integer          not null
#  customer_po           :string(255)
#
# Indexes
#
#  job_fixture_bom_fk_index            (bom_fk)
#  job_fixture_customer_item_fk_index  (customer_item_fk)
#  job_fixture_vendor_item_fk_index    (vendor_item_fk)
#
# Foreign Keys
#
#  fkaf062f87700f8171  (total_id => job_totals.id)
#  fkaf062f87895b1b09  (bom_fk => job_bom.id)
#  fkaf062f87937633a1  (customer_item_fk => job_quote.id)
#  fkaf062f87f51528e1  (vendor_item_fk => job_cost.id)
#
