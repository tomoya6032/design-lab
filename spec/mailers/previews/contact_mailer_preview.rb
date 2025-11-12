# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer_mailer
class ContactMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer_mailer/confirmation
  def confirmation
    ContactMailer.confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer_mailer/notification
  def notification
    ContactMailer.notification
  end

end
