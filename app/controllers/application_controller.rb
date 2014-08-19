class ApplicationController < ActionController::Base
  before_filter :authenticate_user! unless Rails.env.test?
  before_filter :log_data

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def log_data
    if user_signed_in?
      logger.info "User #{current_user.email} requesting #{request.env['PATH_INFO']}."
    else
      logger.info "Unknown user requesting #{request.env['PATH_INFO']}."
    end
  end

end
