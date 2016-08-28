class ShipmentSummaryController < ApplicationController
  def show
    @project = JobProject.find(params[:project_id])
    @fixtures = @project.bom.fixtures
  end
end
