class CutSheet < ApplicationRecord
end

# == Schema Information
#
# Table name: cut_sheets
#
#  id           :integer          not null, primary key
#  job_id       :integer          not null
#  fixture_id   :integer          not null
#  fixture_type :string           not null
#  description  :string           not null
#  manufacturer :string           not null
#  notes        :text             not null
#  pdf_url      :string           not null
#
