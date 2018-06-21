class UsersController < ApplicationController
  before_action :authenticate

  def retire
  end

  def destroy
    if current_user.destroy
      session[:user_id] = nil
      redirect_to root_path, notice: '退会完了しました'
    else
      render :retire
    end
  end
end
