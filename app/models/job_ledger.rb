class JobLedger < ApplicationRecord
  self.table_name = "job_ledger"
  self.primary_key = "job_id"

  belongs_to :bom, foreign_key: :job_id, class_name: "JobBom"

  scope :awarded, -> { where(active_schedule: 1) }
end

# Job Percent of Complete
#
# Notice this table also gives you the ar_billed and ap_billed so you could use those fields to know what
# has been invoiced in Eclipse so you could know your total unbilled amounts as well.
#
# NOTE: When selecting out of this table you will want to include a WHERE clause that only looks for
# active_schedule = 1 so that you only pick up the BOM's that have been awarded.

# == Schema Information
#
# Table name: job_ledger
#
#  job_id           :integer          not null, primary key
#  bom_id           :integer
#  original_cost    :decimal(19, 2)
#  original_sell    :decimal(19, 2)
#  original_margin  :decimal(19, 6)
#  change_cost      :decimal(19, 2)
#  change_sell      :decimal(19, 2)
#  change_margin    :decimal(19, 6)
#  current_cost     :decimal(19, 2)
#  current_sell     :decimal(19, 2)
#  current_margin   :decimal(19, 6)
#  percent_complete :decimal(19, 2)   default(0.0), not null
#  ar_billed        :decimal(19, 2)
#  ap_billed        :decimal(19, 2)
#  total_job_cost   :decimal(19, 2)   default(0.0), not null
#  bidding_sell     :decimal(19, 2)   default(0.0), not null
#
