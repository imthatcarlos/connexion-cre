class JobAdjustment < ApplicationRecord
  self.table_name = "job_adjustment"

  
end

# == Schema Information
#
# Table name: job_adjustment
#
#  id               :integer          not null, primary key
#  bom_id           :integer
#  cost             :decimal(19, 2)
#  sell             :decimal(19, 2)
#  transaction_date :date
#  transaction_id   :string(255)
#  transaction_time :time
#  vendor_id        :integer
#  vendor_name      :string(255)
#
# Indexes
#
#  job_adjustment_bom_id_index  (bom_id)
#
