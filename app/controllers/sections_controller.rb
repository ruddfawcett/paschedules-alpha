class SectionsController < ApplicationController
  before_filter :check_student, only: :show
  def show
    @section = Section.find(params[:id])
    @students = @section.students.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @section } } # Ajax
    end
  end

  def index
  end

  def check_student
    stu = Student.find_by(email: current_user.email)
    if !Section.find(params[:id]).students.include? stu
      redirect_to stu
    end
  end
end
