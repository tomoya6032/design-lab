class Site::JobsController < ApplicationController
  layout 'site'
  before_action :set_site_setting
  before_action :set_job, only: [:show]

  def index
    @jobs = Job.published.ordered
    @job_types = Job.published.job_types
  end

  def show
  end

  private

  def set_site_setting
    @site_setting = Setting.current
  end

  def set_job
    @job = Job.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to site_jobs_path, alert: '指定された求人情報が見つかりません。'
  end
end