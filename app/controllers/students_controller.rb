class StudentsController < ApplicationController
  SectionView = Struct.new(:name, :teacher_name, :room, :type, :time_text, :period_text, 
                           :sd_period_text)
  def names
    names = []
    Student.all.each do |s|
      str = s.full_name
      if !s.pref_name.nil? && !s.pref_name.match(/^[[:space:]]+$/)
        str += " (" + s.pref_name + ")"
      end
      names << { "student" => str }
    end
    render json: names
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
    if @student.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    @schedule = {}
    @student.sections.includes(course: :teacher).each do |s|
      unless s.times.nil?
        s.times.split.each do |per|
          @schedule[per.to_i] = SectionView.new(s.name, s.course.teacher.full_name, s.room)
          if s.name.match(/LUNC-100/)
            @schedule[per.to_i] = SectionView.new(s.name, s.room, "")
          end
        end
      end
    end
    for i in 0..42
      if @schedule[i].nil?
        @schedule[i] = SectionView.new(" ", " ", " ")
      end
    end
    
    for i in EXTENDEDS.keys                      # First, go through extended periods
      if @schedule[i] == @schedule[EXTENDEDS[i]] # If a used double period or double free
        @schedule[EXTENDEDS[i]].type = "SKIP"
        if i > EXTENDEDS[i]
            @schedule[i].time_text = TIMES[EXTENDEDS[i]][0] + "-" + TIMES[i][1]
        else
          @schedule[i].time_text = TIMES[i][0] + "-" + TIMES[EXTENDEDS[i]][1]
        end
        if @schedule[i][0] == " "
          @schedule[i].type = "DOUBLEFREE"
        else
          @schedule[i].type = "DOUBLE"
        end
        @schedule[i].period_text = TIMES[i][2] + "-" + TIMES[EXTENDEDS[i]][2]
      else                      # If its a single period with extended free
        @schedule[i].type = "NORMAL"
        @schedule[EXTENDEDS[i]].type = "FREESHORT"
        @schedule[i].time_text = TIMES[i][0] + "-" + TIMES[i][1]
        @schedule[EXTENDEDS[i]].time_text = TIMES[EXTENDEDS[i]][0] + "-" + TIMES[EXTENDEDS[i]][1]
        @schedule[i].period_text = TIMES[i][2]
        @schedule[EXTENDEDS[i]].period_text = TIMES[EXTENDEDS[i]][2]
      end
    end
    for i in (0..6).to_a + (9..15).to_a + (34..40).to_a # Periods without extendeds
      if @schedule[i] == @schedule[i + 1] && @schedule[i + 1].name != " " # Superdouble, don't count
        @schedule[i].type = "SUPERDOUBLE"                                  # two free's in a row though
        @schedule[i].time_text = TIMES[i][0] + "-" + TIMES[i + 1][1]
        periods = @student.sections.find_by(name: @schedule[i][0]).times
        periods.split(' ').each do |p|
          if EXTENDEDS.keys.include?(p.to_i)
            @schedule[i].sd_period_text = TIMES[p.to_i][2]
            break
          end
        end
        @schedule[i].period_text = TIMES[i][2] + "-" + TIMES[i + 1][2]
        @schedule[i + 1].type = "SKIP"
      elsif @schedule[i].type != "SKIP"
        if @schedule[i].name == " "
          @schedule[i].type = "NORMALFREE"
        else
          @schedule[i].type = "NORMAL"
        end
        @schedule[i].time_text = TIMES[i][0] + "-" + TIMES[i][1]
        @schedule[i].period_text = TIMES[i][2]
      end
    end

    respond_to do |format|
      format.png do
        gen_html = render_to_string :action => "show_png.html.erb", :layout => "png"
        @kit = IMGKit.new(gen_html, width: 600, height: 730)
        
        send_data(@kit.to_png, type: "image/png", disposition: "inline")
      end
      
      format.html
    end
  end  
end
