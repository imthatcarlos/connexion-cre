class JobProject < ApplicationRecord
  self.table_name = "job_project"

  has_many :quoted_boms, foreign_key: :job_id, class_name: 'JobBom'
  belongs_to :bom, foreign_key: :awardedschedule_id, primary_key: :id, class_name: 'JobBom'

  def job_number
    "#{job_cat.first(2)}-#{serialized_bid_date}-#{id}"
  end

  def serialized_bid_date
    return 'MISSING_BID_DATE' unless bid_date_time
    bid_date_time.strftime('%m%e%y')
  end
end

# ECLIPSE
# bidder = Eclipse Writer
# inside_sales = Eclipse Inside Salesman for awarded Customer
# outside_sales = Eclipse Outside Salesman for awarded Customer
# credit_br = Eclipse Billing Branch Number
# ship_from_br = Eclipse Shipping Branch Number

# MISC
# id = job number which is the last number following dash in example above this is 437
# Note: The full job number is the First two letters of the job_cat followed by a dash
# followed by the bid date in the format mmddyy followed by a dash followed by id.

# == Schema Information
#
# Table name: job_project
#
#  id                  :integer          not null, primary key
#  name                :string(255)      not null
#  state               :string(255)
#  optlock             :integer
#  job_cat             :string(255)
#  status              :string(255)
#  city                :string(255)
#  inside_sales        :string(255)
#  outside_sales       :string(255)
#  follow_up_date      :date
#  rebid_date          :date
#  bidder              :string(255)
#  project_manager     :string(255)
#  completion_date     :date
#  next_action         :string(255)
#  architect           :string(255)
#  engineer            :string(255)
#  no_bid              :boolean
#  job_lost_reason     :string(255)
#  take_off            :boolean
#  approval_req        :boolean
#  created_date        :datetime
#  awardedcustomer_id  :integer
#  awardedschedule_id  :integer
#  job_lost            :boolean
#  credit_br           :string(255)
#  ship_from_br        :string(255)
#  job_lost_competitor :string(255)
#  job_project_type    :string(255)
#  job_win_confidence  :string(255)
#  pgm_version         :integer
#  bid_date_time       :datetime         not null
#  batch_id            :string(255)
#
# Indexes
#
#  job_project_awardedcustomer_id_index  (awardedcustomer_id)
#  job_project_bidder                    (bidder)
#  job_project_project_manager           (project_manager)
#
# Foreign Keys
#
#  fkcedc809781a4afba  (awardedcustomer_id => job_customer.id)
#  fkcedc8097b23f71ec  (awardedschedule_id => job_bom.id)
#
