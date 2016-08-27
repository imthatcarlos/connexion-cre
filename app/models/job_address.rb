class JobAddress < ApplicationRecord
  self.table_name = "job_address"
end

# == Schema Information
#
# Table name: job_address
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  state        :string(255)
#  country      :string(255)
#  addl_address :string(255)
#  city         :string(255)
#  phone        :string(255)
#  street       :string(255)
#  zipcode      :string(255)
#  email        :string(255)
#  fax          :string(255)
#  addl_name    :string(255)
#
