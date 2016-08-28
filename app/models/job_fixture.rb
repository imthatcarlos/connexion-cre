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
end

# In cases where you need to get detail information about what items have been released and received both in quantity and dollars you have to build some views in Job Management that pulls together both
# fixture and component line item information. Components are sub-component of regular fixture Items. Eclipse created two tables for these items even though they essentially have the same information.
# Because of this the only way I know how to do this is create Fixture Totals View and a Component Totals View and then combine those views in a Summary view.
