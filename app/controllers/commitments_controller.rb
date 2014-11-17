class CommitmentsController < ApplicationController
  def show
    @commitment = Commitment.find(params[:id])
    @students = Kaminari.paginate_array(@commitment.students.sort_by { |a| a.last_name.downcase }).page(params[:page]).per(@commitment.students.count > 20 ? 15 : 20)

    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @commitment } } # Ajax
    end
  end
end
