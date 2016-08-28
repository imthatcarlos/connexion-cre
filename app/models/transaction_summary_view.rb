class TransactionSummaryView < ApplicationRecord
  self.table_name = "TransactionSummaryView"

  scope :financial, -> { where.not(order_code: 'receiveOrder') }
  scope :vendor, -> { where(order_code: 'receiveOrder') }
  scope :stock, -> { where(vendor_id: -1, vendor_name: 'Stock') }
end

# ECLIPSE
# hold_id = The first part of this id in front of the .1 is the actual Sales Order ID it
# created in Eclipse
# vendor_id = The Eclipse ID for the vendor.

# MISC
# The order code will have several types. If you are trying to
# duplicate the information in the Transactions section as is
# shown above then you would exclude any orders codes called
# receiveOrder. receiveOrder transactions would be what
# shows in the vendor invoice section.
#
# Orders coming from stock will have a vendor_id of -1 and a
# vendor_name of Stock
#
# Note: The Job Management Database only shows the vendor
# side transactions for invoices. It gets all of it's customer
# invoice information from Eclipse.
# For invoices to vendor do not use TransactionSummaryView
# but instead use job_receive table selecting on bom_id and
# using the reconcile_amt field for the dollar amount.

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
