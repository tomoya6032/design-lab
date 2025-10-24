class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.order(created_at: :desc)
    @total_users = @users.count
    @recent_users = @users.where('created_at > ?', 1.week.ago).count
  end

  def show
  end

  def edit
  end

  def update
    # パスワードが空の場合は更新パラメータから除外
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'ユーザー情報が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: '自分自身は削除できません。'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'ユーザーが削除されました。'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role, :password, :password_confirmation)
  end
end