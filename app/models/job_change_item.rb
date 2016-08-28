class JobChangeItem < ApplicationRecord
  self.table_name = "job_change_item"

  belongs_to :job_order, foreign_key: :order_fk, class_name: "JobOrder"
  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end

# == Schema Information
#
# Table name: job_change_item
#
#  id                 :integer          not null, primary key
#  transaction_qty    :integer
#  new_description    :string(255)
#  status             :integer
#  new_price          :decimal(19, 3)
#  new_cost           :decimal(19, 3)
#  new_stock_pn       :string
#  new_vendor         :integer
#  new_extended_cost  :decimal(19, 2)
#  new_extended_price :decimal(19, 2)
#  new_fixture_type   :string(255)
#  old_description    :string(255)
#  old_status         :integer
#  old_quantity       :integer
#  extend             :boolean
#  old_cost           :decimal(19, 3)
#  old_fixture_type   :string(255)
#  old_price          :decimal(19, 3)
#  old_extended_cost  :decimal(19, 2)
#  old_extended_price :decimal(19, 2)
#  fixture_fk         :integer
#  order_fk           :integer
#  component_fk       :integer
#  transaction_fkey   :integer
#  qty_uom            :string(255)
#  old_qty_uom        :string(255)
#  um_qty             :integer
#  old_um_qty         :integer
#  pricing_uom        :string(255)
#  old_pricing_uom    :string(255)
#  price_per_qty      :integer
#  old_price_per_qty  :integer
#  hfr_quantity       :integer
#
# Indexes
#
#  job_change_item_component_fk_index  (component_fk)
#  job_change_item_fixture_fk_index    (fixture_fk)
#  job_change_item_order_fk_index      (order_fk)
#
# Foreign Keys
#
#  fkea7734c06485c84c  (transaction_fkey => job_transaction_log.id)
#  fkea7734c0724bd8e4  (fixture_fk => job_fixture.fixture_id)
#  fkea7734c09323e436  (order_fk => job_change.id)
#  fkea7734c0c82bfc64  (component_fk => job_component.fixture_id)
#
