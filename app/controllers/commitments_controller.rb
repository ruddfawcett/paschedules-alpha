class CommitmentsController < ApplicationController
  before_filter :check_student, only: :show

  def show
    @commitment = Commitment.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @commitment } } # Ajax
    end
  end

  def check_student
    stu = Student.find_by(email: current_user.email)
    if !Commitment.find(params[:id]).students.include? stu
      redirect_to stu
    end
  end
end
