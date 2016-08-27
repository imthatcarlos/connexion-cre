class ShipmentSummaryController < ApplicationController
  def show
    @rows = []
    @cut_booklet_link = "http://google.com"
    @customer_po = "HHHH"
    @project_manager_info = "Name, Phone Number, Email address"
    @project_name = JobProject.find(params[:id]).name || "Project Name"
    @contact_info = "Contact name, phone number, email address"
    @additional_contacts = ""
  end
end
