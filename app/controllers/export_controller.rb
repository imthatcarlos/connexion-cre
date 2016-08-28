require 'csv'

class ExportController < ApplicationController

  def email
    @project = JobProject.find(params[:project_id])
    @fixtures = @project.bom.fixtures

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
    project = JobProject.find(params[:project_id])
    fixtures = project.bom.fixtures

    result = CSV.generate do |csv|
      csv << csv_header
      fixtures.each_with_object(csv) { |f, obj| 
        obj << f.to_csv 
        f.shipments.each_with_object(obj) { |s, obj2| 
          obj2 << [ nil, nil, "shipment", s.quantity, s.shipment_date, s.ship_date, s.shipper, s.tracking_number ] 
        }
      }
    end

    send_data(result, {
      filename:    "shipping-summary-customer-po-{project.customer_po}.csv",
      type:        "text/csv",
      disposition: "attachment"
    })
  end

  def pdf
    @project  = JobProject.find(params[:project_id])
    @fixtures = @project.bom.fixtures

    render pdf:              'shipping-summary-customer-po-{@project.customer_po}',
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
      "Quantity",
      "Est Ship Date",
      "Actual Ship Date",
      "Shipper",
      "Tracking No."
    ]
  end
end