class StudentsController < ApplicationController
  def index
    arr = params[:search].split(' ')
    if arr.length > 4
      arr = arr.first(4)
      flash[:error] = "Too many search terms"
    end
    
    @students = []
    arr.each_with_index do |a, idx|
      q = Student.search(full_name_or_first_name_or_last_name_or_pref_name_cont: a)
      if idx == 0
        @students = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @students = @students.select { |s| tmpArr.include? s }
      end
      q = nil
    end

    @students.uniq
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

    respond_to do |format|
      format.png do
        gen_html = render_to_string :action => "show_png.html.erb", :layout => "png"
        @kit = IMGKit.new(gen_html, width: 700, height: 800)
        
        send_data(@kit.to_png, type: "image/png", disposition: "inline")
      end
      
      format.html
    end
  end  
end
