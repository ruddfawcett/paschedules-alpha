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
  end
end
