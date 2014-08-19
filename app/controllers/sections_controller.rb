class SectionsController < ApplicationController
  def show
    @section = Section.find(params[:id])
    @students = Kaminari.paginate_array(@section.students.sort { |a, b| a.last_name.downcase <=> b.last_name.downcase }).page(params[:page]).per(@section.students.count > 20 ? 15 : 20)
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @section } } # Ajax
    end
  end

  def index
  end
end
