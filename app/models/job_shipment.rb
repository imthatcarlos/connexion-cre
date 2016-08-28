class JobShipment < ApplicationRecord
  self.table_name =  "job_shipment"

  belongs_to :fixture, foreign_key: :fixture_fk, class_name: "JobFixture"
end

# == Schema Information
#
# Table name: job_shipment
#
#  id               :integer          not null, primary key
#  quantity         :integer
#  ship_date        :date
#  follow_up_date   :datetime
#  shipment_date    :date
#  shipper          :string(255)
#  tracking_number  :string(255)
#  external_note    :string(255)
#  internal_note    :string(255)
#  component_fk     :integer
#  fixture_fk       :integer
#  country_origin   :string(255)
#  htc_code         :string(255)
#  required_on_site :date
#  required_release :date
#  erp_ship_id      :string(255)
#
# Indexes
#
#  job_shipment_component_fk_index  (component_fk)
#  job_shipment_fixture_fk_index    (fixture_fk)
#
# Foreign Keys
#
#  fk2973ebdc724bd8e4  (fixture_fk => job_fixture.fixture_id)
#  fk2973ebdcc82bfc64  (component_fk => job_component.fixture_id)
#
