class SupercoursesController < ApplicationController
  def show
    @course = Supercourse.find(params[:id])
    if @course.courses.count == 1
      redirect_to @course.courses.first
    end
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