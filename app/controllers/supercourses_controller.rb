class SupercoursesController < ApplicationController
  def show
    flash.now[:warning] = "All class lists are incomplete until the 364 new students have finalized their courses and have had their schedules released by the registrar."
    @course = Supercourse.find(params[:id])
    @courses = @course.courses.includes(:teacher).sort_by { |x| x.teacher.last_name }
    # if @course.courses.count == 1
    #   redirect_to @course.courses.first
    # end
  end

  def names
    names = []
    Supercourse.all.each do |c|
      str = c.name + ": " + c.title
      names << { "course" => str }
    end
    render json: names
  end
end
