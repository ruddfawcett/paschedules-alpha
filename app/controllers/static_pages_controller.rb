class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      student = Student.find_by(email: current_user.email)
      if student
        redirect_to student
      end
    else
      render layout: "devise"
    end
  end

  def contact
  end

end
