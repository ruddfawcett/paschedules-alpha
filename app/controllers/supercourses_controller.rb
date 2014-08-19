class SupercoursesController < ApplicationController
  def show
    @course = Supercourse.find(params[:id])
    @courses = @course.courses.sort { |a, b| a.teacher.last_name <=> b.teacher.last_name }
    @sections = Hash.new()
    @courses.each do |c|
      @sections[c] = c.sections.sort { |a, b| a.name <=> b.name }
    end
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
