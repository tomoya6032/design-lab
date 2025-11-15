class Admin::JobApplicationsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_job_application, only: [:show, :destroy, :update_status]

  def index
    @job_applications = JobApplication.includes(:job)
                                      .order(created_at: :desc)
                                      .page(params[:page])
                                      .per(20)
    
    # ステータスでフィルタリング
    if params[:status].present?
      @job_applications = @job_applications.where(status: params[:status])
    end
    
    # 求人でフィルタリング
    if params[:job_id].present?
      @job_applications = @job_applications.where(job_id: params[:job_id])
    end
    
    @jobs = Job.all.order(:title)
    @status_counts = JobApplication.group(:status).count
  end

  def show
    # 詳細表示用
  end

  def update_status
    if @job_application.update(status: params[:status])
      redirect_to admin_job_applications_path, notice: 'ステータスを更新しました。'
    else
      redirect_to admin_job_applications_path, alert: 'ステータスの更新に失敗しました。'
    end
  end

  def destroy
    @job_application.destroy
    redirect_to admin_job_applications_path, notice: '応募を削除しました。'
  end

  private

  def set_job_application
    @job_application = JobApplication.find(params[:id])
  end

  def status_params
    params.permit(:status)
  end
end