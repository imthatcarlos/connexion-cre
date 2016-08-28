class JobShipment < ApplicationRecord
  self.table_name =  "job_shipment"

  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end