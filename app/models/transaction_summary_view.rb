class TransactionSummaryView < ApplicationRecord
  self.table_name = "TransactionSummaryView"
end

# == Schema Information
#
# Table name: TransactionSummaryView
#
#  vendor_id        :integer
#  vendor_name      :string(255)
#  ship_date        :date
#  po_num           :string
#  hold_id          :string(255)
#  total_cost       :decimal(19, 2)
#  total_sell       :decimal(, )
#  order_code       :text
#  document_fk      :string
#  bom_id           :integer
#  id               :integer
#  transaction_time :time
#
