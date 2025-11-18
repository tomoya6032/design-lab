class Site::ContactsController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_contact, only: [:show]
  
  def new
    @contact = Contact.new
  end

  def test
    @contact = Contact.new
  end

  def debug
    @contact = Contact.new
  end

  def simple
    @contact = Contact.new
  end
  
  def create
    @contact = Contact.new(contact_params)
    
    # IPアドレスとUser-Agentを記録
    @contact.ip_address = request.remote_ip
    @contact.user_agent = request.user_agent
    
    # ハニーポット検証（ボット対策）
    if params[:website].present?
      # ハニーポットに値が入っている場合はボットとみなしてエラー
      @contact.status = :spam
      @contact.save
      redirect_to root_path, alert: 'エラーが発生しました。'
      return
    end
    
    # reCAPTCHA検証（一時的に無効化）
    # if Rails.env.production?
    #   unless verify_recaptcha(model: @contact)
    #     render :new, status: :unprocessable_entity
    #     return
    #   end
    # end
    
    if @contact.save
      # メール送信（開発環境では送信をスキップ）
      unless Rails.env.development?
        begin
          ContactMailer.confirmation(@contact).deliver_now
          ContactMailer.notification(@contact).deliver_now
        rescue => e
          Rails.logger.error "メール送信エラー: #{e.message}"
        end
      else
        Rails.logger.info "開発環境: メール送信をスキップしました (Contact ID: #{@contact.id})"
      end
      
      redirect_to thank_you_contact_path(@contact), notice: 'お問い合わせを送信しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    # 問い合わせ詳細表示（必要に応じて）
  end
  
  def thank_you
    @contact = Contact.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_contact_path, alert: 'お問い合わせが見つかりません。'
  end
  
  private
  
  def set_contact
    @contact = Contact.find(params[:id])
  end
  
  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end