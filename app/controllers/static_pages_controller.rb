class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      redirect_to Student.find_by(email: current_user.email)
    else
      render layout: "devise"
    end
  end
end
