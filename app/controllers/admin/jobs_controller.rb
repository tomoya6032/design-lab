class Admin::JobsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_job, only: [:show, :edit, :update, :destroy, :destroy_image]

  def index
    @jobs = Job.all.ordered
  end

  def show
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    
    if @job.save
      redirect_to admin_jobs_path, notice: '求人情報を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to admin_jobs_path, notice: '求人情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    redirect_to admin_jobs_path, notice: '求人情報を削除しました。'
  end

  def destroy_image
    attachment = ActiveStorage::Attachment.find(params[:id])
    
    if attachment && attachment.record == @job
      attachment.purge
      redirect_to edit_admin_job_path(@job), notice: '画像を削除しました。'
    else
      redirect_to edit_admin_job_path(@job), alert: '画像が見つかりませんでした。'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_admin_job_path(@job), alert: '画像が見つかりませんでした。'
  end

  private

  def set_job
    @job = Job.find(params[:id] || params[:job_id])
  end

  def job_params
    params.require(:job).permit(
      :title, :job_type, :description, :capacity, :salary_range, 
      :expectations, :senior_message, :published, :display_order,
      hero_images: [], detail_images: []
    )
  end
end