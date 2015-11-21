class ApplicationController < ActionController::Base
  before_filter :authenticate_user! unless Rails.env.test?
  before_filter :log_data

  # before_filter :original_url
  #
  # def original_url
  #   if request.original_url.include? 'herokuapp'
  #     redirect_to 'http://paschedul.es'
  #   end
  # end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def log_data
    req = request.env['PATH_INFO']
    case req
    when /\/students\/(\d+)/
      info = Student.find($1.to_i).email
    when /\/supercourses\/(\d+)/
      info = Supercourse.find($1.to_i).name
    when /\/sections\/(\d+)/
      info = Section.find($1.to_i).name
    when /\/teachers\/(\d+)/
      info = Teacher.find($1.to_i).email
    else
      info = nil
    end

    req << " (#{info})" if info
    if user_signed_in?
      logger.info "User #{current_user.email} requesting #{req}."
    else
      logger.info "Unknown user requesting #{req}."
    end
  end

  if Rails.env.production?
    rescue_from(ActionView::MissingTemplate) do |e|
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
