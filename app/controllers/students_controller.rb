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
    
    for i in EXTENDEDS.keys                      # First, go through extended periods
      if @schedule[i] == @schedule[EXTENDEDS[i]] # If a used double period or double free
        @schedule[EXTENDEDS[i]][3] = "SKIP"
        @schedule[i][4] = TIMES[i][0] + "-" + TIMES[EXTENDEDS[i]][1]
        if @schedule[i][0] == " "
          @schedule[i][3] = "DOUBLEFREE"
        else
          @schedule[i][3] = "DOUBLE"
        end
        @schedule[i][5] = TIMES[i][2] + "-" + TIMES[EXTENDEDS[i]][2]
      else                      # If its a single period with extended free
        @schedule[i][3] = "NORMAL"
        @schedule[EXTENDEDS[i]][3] = "FREESHORT"
        @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i][1]
        @schedule[EXTENDEDS[i]][4] = TIMES[EXTENDEDS[i]][0] + "-" + TIMES[EXTENDEDS[i]][1]
        @schedule[i][5] = TIMES[i][2]
        @schedule[EXTENDEDS[i]][5] = TIMES[EXTENDEDS[i]][2]
      end
    end
    for i in (0..6).to_a + (9..15).to_a + (34..40).to_a # Periods without extendeds
      if @schedule[i] == @schedule[i + 1] && @schedule[i + 1][0] != " " # Superdouble, don't count
        @schedule[i][3] = "SUPERDOUBLE"                                 # two free's in a row though
        @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i + 1][1]
        @schedule[i][5] = TIMES[i][2] + "-" + TIMES[i + 1][2]
        @schedule[i + 1][3] = "SKIP"
      elsif @schedule[i][3] != "SKIP"
        if @schedule[i][0] == " "
          @schedule[i][3] = "NORMALFREE"
        else
          @schedule[i][3] = "NORMAL"
        end
        @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i][1]
        @schedule[i][5] = TIMES[i][2]
      end
    end
    # Old buggy code...
        # if (7..8) === i || (16..17) === i || (18..33) === i || (41..42) === i
    #       if @schedule[i][0] == " "
    #         @schedule[i][3] = "DOUBLEFREE"
    #       else
    #         @schedule[i][3] = "DOUBLE"
    #       end
    #       @schedule[i][4] = TIMES[i][0] + "-" + TIMES[EXTENDEDS[i]][1]
    #       @schedule[i][5] = TIMES[i][2]
    #     else
    #       @schedule[i][3] = "SUPERDOUBLE"
    #       @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i + 1][1]
    #       @schedule[i][5] = TIMES[i][2] + "-" + TIMES[i + 1][2]
    #     end
    #     @schedule[i+1][3] = "SKIP"
    #     i += 1 # What kind of language doesn't have the ++ operator?!!!
    #   end
    #   i += 1
    # end
    # for i in [8, 17, 19, 20, 23, 24, 27, 28, 31, 33, 41]
    #   if @schedule[i][3].nil?
    #     @schedule[i][3] = "FREESHORT"
    #     @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i][1]
    #     @schedule[i][5] = TIMES[i][2]
    #   end
    # end
    # for i in (0..6).to_a + (9..15).to_a + (34..40).to_a
    #   if @schedule[i][3].nil?
    #     if @schedule[i][0] == " "
    #       @schedule[i][3] = "NORMALFREE"
    #     else
    #       @schedule[i][3] = "NORMAL"
    #     end
    #     @schedule[i][4] = TIMES[i][0] + "-" + TIMES[i][1]
    #     @schedule[i][5] = TIMES[i][2]
    #   end
      #  end=
  end
end
