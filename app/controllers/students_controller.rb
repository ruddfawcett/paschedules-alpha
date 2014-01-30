class StudentsController < ApplicationController
  def index
  end

  def show
    id = params[:id]
    @student = nil # Do you need this? In java/C you would...
    if id.match(/^\d{7}$/)
      @student = Student.find_by(pa_id: id)
    elsif id.match(/^\d+$/)
      @student = Student.find(id)
    else
      @student = Student.find_by(email: "#{id}@andover.edu")
    end
    @schedule = {}
    @student.sections.each do |s|
      s.times.split.each do |per|
        @schedule[per.to_i] = [s.name, s.course.teacher.full_name, s.room] 
        if s.name.match(/LUNC-100/)
          @schedule[per.to_i] = [s.name, s.room, ""]
        end
      end
    end
    for i in 0..42
      if @schedule[i].nil?
        @schedule[i] = [" ", " ", " "]
      end
    end
    i = 0
    require 'pp'
    pp @schedule
    while i < 41
      pp @schedule[i]
      if @schedule[i] == @schedule[i+1] && @schedule[i][0] != " "
        if (7..8) === i || (16..17) === i || (18..33) === i || 41 === i
          @schedule[i][3] = "DOUBLE"
        else
          @schedule[i][3] = "SUPERDOUBLE"
        end
        @schedule[i+1][3] = "SKIP"
        i += 1 # What kind of language doesn't have the ++ operator?!!!
      elsif [8, 17, 19, 20, 23, 24, 27, 28, 31, 33, 42].include?(i)
        @schedule[i][3] = "FREESHORT"
      else 
        @schedule[i][3] = "NORMAL"
      end
      i += 1
    end
  end
end
