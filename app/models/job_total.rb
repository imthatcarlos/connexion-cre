class JobTotal < ApplicationRecord
  has_one :fixture, foreign_key: :total_id, class_name: "JobFixture"
  has_one :component, foreign_key: :total_id, class_name: "JobComponent"
end

# == Schema Information
#
# Table name: job_totals
#
#  id                 :integer          not null, primary key
#  return_qty         :integer
#  change_qty         :integer
#  pending_qty        :integer
#  release_qty        :integer
#  receive_qty        :integer
#  receive_return_qty :integer
#
