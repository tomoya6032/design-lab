class Site::JobApplicationsController < ApplicationController
  before_action :set_job
  before_action :set_breadcrumbs

  def new
    @job_application = JobApplication.new
    @job_application.job = @job
  end

  def create
    Rails.logger.debug "Params: #{params.inspect}"
    Rails.logger.debug "Job Application Params: #{params[:job_application].inspect}"
    @job_application = JobApplication.new(job_application_params)
    @job_application.job = @job

    if params[:preview] || params[:commit] == '確認画面へ'
      if @job_application.valid?
        render :confirm
      else
        render :new, status: :unprocessable_entity
      end
    else
      if @job_application.save
        # TODO: メール送信機能を実装
        redirect_to site_job_job_application_path(@job, @job_application), notice: 'ご応募ありがとうございます。追って担当者よりご連絡いたします。'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def confirm
    @job_application = JobApplication.new(job_application_params)
    @job_application.job = @job
    
    unless @job_application.valid?
      render :new, status: :unprocessable_entity
    end
  end

  def create_confirmed
    @job_application = JobApplication.new(job_application_params)
    @job_application.job = @job

    if @job_application.save
      # TODO: メール送信機能を実装
      redirect_to site_job_job_application_path(@job, @job_application), notice: 'ご応募ありがとうございます。追って担当者よりご連絡いたします。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @job_application = JobApplication.find(params[:id])
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { name: 'ホーム', path: site_root_path },
      { name: '求人情報', path: site_jobs_path },
      { name: @job.title, path: site_job_path(@job) },
      { name: 'エントリー', path: nil }
    ]
  end

  def job_application_params
    params.require(:job_application).permit(:name, :email, :phone, :resume, :cover_letter, :portfolio_url, :experience_years, :motivation)
  end
end