class JobContact < ApplicationRecord
  self.table_name = "job_contact"

  belongs_to :address, foreign_key: :address_fk, class_name: 'JobAddress'
end

# == Schema Information
#
# Table name: job_contact
#
#  id             :integer          not null, primary key
#  contact_id     :integer
#  contact_method :string(255)
#  address_fk     :integer
#
