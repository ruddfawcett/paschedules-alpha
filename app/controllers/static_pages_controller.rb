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
  
  def search
    @arr = params[:search].split(' ')
    if @arr.length == 1
      @q = Student.search(first_name_or_last_name_or_pref_name_cont: @arr[0])
    elsif @arr.length == 2
      @q = Student.search(first_name_or_pref_name_cont: @arr[0], last_name_cont: @arr[1])
    end
    if @q.nil?
      @students = nil
    else
    @students = @q.result(distinct: true)
    end
  end
end
