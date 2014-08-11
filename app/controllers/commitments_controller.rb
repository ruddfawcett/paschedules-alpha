class CommitmentsController < ApplicationController
  def show
    @commitment = Commitment.find(params[:id])
    @students = @commitment.students.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @commitment } } # Ajax
    end
  end
end
