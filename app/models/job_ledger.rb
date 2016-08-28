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