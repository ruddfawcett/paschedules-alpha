class TeachersController < ApplicationController
  def index
    names = []
    Teacher.all.each do |s|
      names << { "teacher" => s.full_name }
    end
    render json: names
  end
  
  def show
    @teacher = Teacher.find(params[:id])
  end
end
