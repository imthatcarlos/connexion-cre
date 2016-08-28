class ShippingSummaryMailer < ApplicationMailer
  def send(email, attachment_filepath)
    subject = "Connexion - Shipping Summary"
    attachments['shipping-summary'] = File.read(attachment_filepath)
    mail(to: email, subject: subject)
  end
end