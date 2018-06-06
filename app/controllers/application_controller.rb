class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  rescue_from Exception, with: :error500
  rescue_from ActiveRecord::RecordNotFound, with: :error404

  private

  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  def logged_in?
    !!session[:user_id]
  end

  def authenticate
    return if logged_in?
    redirect_to root_path, alert: 'ログインしてください'
  end

  def error404(_e)
    render 'error404', status: :not_found, formats: [:html]
  end

  def error500(e)
    logger.error [e, *e.backtrace].join("\n")
    render 'error500', status: :internal_server_error, formats: [:html]
  end
end
