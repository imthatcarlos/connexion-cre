require 'csv'

class ExportController < ApplicationController

  def email
    project_id      = params[:project_id]
    @customer_po    = params[:customer_po]
    
    # probs get these from project
    @address        = "Some address"
    @contact_email  = "some@email.com"
    @contact_name   = "some name"
    @phone          = "44444444"
    @fax            = "fax"

    @rows = []

    pdf = render_to_string pdf: "shipping-summary-customer-po-#{customer_po}", 
                          template: "views/export/shipping_summary",
                          locals: { 
                            customer_po: @customer_po,
                            address: @address,
                            contact_email: @contact_email,
                            contact_name: @contact_name,
                            phone: @phone,
                            fax: @fax,
                            rows: @rows
                          }

    save_path = Rails.root.join('tmp','shipping-summary-customer-po-#{customer_po}.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    ShippingSummaryMailer.send(email, save_path)
  end
  
  def csv
    customer_po = params[:customer_po]
    project_id  = params[:project_id]

    result = CSV.generate do |csv|
      csv << csv_header
      records = []
      records.each { |r| csv << r }
    end

    send_data(result, {
      filename:    "shipping-summary-customer-po-#{customer_po}.csv",
      type:        "text/csv",
      disposition: "attachment"
    })
  end

  def pdf
    project_id      = params[:project_id]
    @customer_po    = params[:customer_po]
    @address        = "Some address"
    @contact_email  = "some@email.com"
    @contact_name   = "some name"
    @phone          = "44444444"
    @fax            = "fax"

    @rows = []

    render pdf:              'shipping-summary-customer-po-#{@customer_po}',
           disposition:      'attachment',
           template:         'export/shipping_summary',
           orientation:      'Landscape',
           title:            'Shipping Summary'

  end

  def csv_header
    [
      "Type",
      "Vendor",
      "Description",
      "Order QTY",
      "Status",
      "QTY",
      "Est",
      "Ship",
      "Date",
      "Actual",
      "Ship",
      "Date",
      "Shipper",
      "On Hold",
      "External",
      "Notes",
      "Submittal Status",
      "Cut Sheet",
      "Installation"
    ]
  end
end