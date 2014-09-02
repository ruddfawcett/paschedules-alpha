class TeachersController < ApplicationController
  def names
    names = []
    Teacher.all.each do |s|
      next if s.full_name.nil?
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
    @sections = @teacher.courses.includes(:sections).map(&:sections).flatten.sort_by(&:name)
  end
end
