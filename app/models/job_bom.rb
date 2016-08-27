class JobBom < ApplicationRecord
  self.table_name = "job_bom"
  self.inheritance_column = nil

  has_many :fixtures, foreign_key: :bom_fk, class_name: "JobFixture"
  belongs_to :project, foreign_key: :job_id, class_name: "JobProject"
end

# There can be multiple BOM's tied to a job during quoting phase. Once a job is awarded
# only one BOM can be selected with it's id put in the job_project.awardedschedule_id field.
#
# active_schedule = will also be set to true if it is the awarded schedule
#
# You can use the id field to link to the job_fixture table to get the detail information of what
# items make up the bom cost and sell.

# == Schema Information
#
# Table name: job_bom
#
#  id               :integer          not null, primary key
#  optlock          :integer
#  category         :string(255)
#  description      :string(255)
#  job_id           :integer
#  stock_on_hold    :date
#  transaction_time :time
#  total_margin     :decimal(19, 6)
#  total_markup     :decimal(19, 6)
#  total_ext_cost   :decimal(19, 2)
#  total_ext_price  :decimal(19, 2)
#  active_schedule  :boolean
#  lock_cost        :boolean
#  lock_sell        :boolean
#  default_customer :string(255)
#  rows_per_page    :integer
#  type             :integer
#  quote_number     :string(255)
#
# Foreign Keys
#
#  fkaa50223ed6b513aa  (job_id => job_project.id)
#
