class SectionsController < ApplicationController
  def show
    flash.now[:warning] = "All class lists are incomplete until the 364 new students have finalized their courses and have had their schedules released by the registrar."
    @section = Section.find(params[:id])
    @students = Kaminari.paginate_array(@section.students.sort_by { |a| a.last_name.downcase }).page(params[:page]).per(@section.students.count > 20 ? 15 : 20)
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @section } } # Ajax
    end
  end

  def index
  end
end
