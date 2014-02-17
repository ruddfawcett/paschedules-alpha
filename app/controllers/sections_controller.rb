class SectionsController < ApplicationController
  def show
    @section = Section.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render partial: 'ajax_show.js.erb', locals: { section: @section } } # Ajax
    end
  end

  def index
  end
end
