class ContactMailer < ApplicationMailer
  default from: Rails.application.credentials.email&.dig(:from) || 'noreply@design-cms.com'
  
  # お客様への受付完了メール
  def confirmation(contact)
    @contact = contact
    @inquiry_number = "INQ-#{contact.id.to_s.rjust(6, '0')}"
    
    mail(
      to: @contact.email,
      subject: 'お問い合わせを受付いたしました'
    )
  end

  # 管理者への通知メール
  def notification(contact)
    @contact = contact
    @inquiry_number = "INQ-#{contact.id.to_s.rjust(6, '0')}"
    
    # 管理者のメールアドレス（設定から取得または環境変数）
    admin_email = Rails.application.credentials.email&.dig(:admin) || ENV['ADMIN_EMAIL'] || 'mopa6032@gmail.com'
    
    mail(
      to: admin_email,
      subject: "【新規お問い合わせ】#{@contact.subject}"
    )
  end
end
