class JobBom < ApplicationRecord
  self.table_name = "job_bom"

  has_many :projects, foreign_key: :job_id, class_name: "JobProject"
end

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
