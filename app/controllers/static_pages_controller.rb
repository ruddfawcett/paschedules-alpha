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
    arr = params[:search].split(' ')
    if arr.length > 4
      arr = arr.first(4)
      flash[:error] = "Too many search terms"
    end
    # if @arr.length == 1
    #   @q = Student.search(first_name_or_last_name_or_pref_name_cont: @arr[0])
    # elsif @arr.length == 2
    #   @q = Student.search(first_name_or_pref_name_cont: @arr[0], last_name_cont: @arr[1])
    # else
    #   @q = Student.search(full_name_cont: @arr.join(' '))
    # end
    
    @students = []
    arr.each_with_index do |a, idx|
      q = Student.search(full_name_or_first_name_or_last_name_or_pref_name_cont: a)
      if idx == 0
        @students = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @students = @students.select { |s| tmpArr.include? s }
      end
      q = nil
    end
    #if @q.nil?
    #  @students = nil
    #else
    #@students = @q.result(distinct: true)
    @students.uniq
  end
end
