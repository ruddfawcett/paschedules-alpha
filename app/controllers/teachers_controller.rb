class TeachersController < ApplicationController
  def names
    names = []
    Teacher.all.each do |s|
      str = s.full_name
      if !s.pref_name.nil? && !s.pref_name.match(/^[[:space:]]+$/)
        str += " (" + s.pref_name + ")"
      end
      names << { "teacher" => str }
    end
    render json: names
  end

  def show
    @teacher = Teacher.find(params[:id])
    # I'm prety sure there's a way to do this with SQL so the database does the heavy lifting
    # This will result in a lot of queries for sections
    # For our tiny DB size though, it really doesn't matter
    @sections = @teacher.courses.map(&:sections).flatten.sort_by(&:name)
  end
end
