class JobReceive < ApplicationRecord
  self.table_name = "job_receive"
end

# == Schema Information
#
# Table name: job_receive
#
#  id               :integer          not null, primary key
#  vendor_name      :string(255)
#  vendor_id        :integer
#  transaction_id   :string(255)
#  payable_id       :string(255)
#  total_cost       :decimal(19, 2)
#  transaction_date :date
#  transaction_time :time
#  total_sell       :decimal(19, 2)
#  reconcile_amt    :decimal(19, 2)
#  bom_id           :integer
#  fee_payable      :string(255)
#  fee_fk           :integer
#  fee_amount       :decimal(19, 2)
#
# Indexes
#
#  job_receive_bom_id_index  (bom_id)
#
# Foreign Keys
#
#  fk21cea861f65080a4  (fee_fk => job_fees.id)
#
