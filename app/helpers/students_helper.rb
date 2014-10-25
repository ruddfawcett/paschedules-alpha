module StudentsHelper
  SectionView = Struct.new(:name, :teacher_name, :room, :type, :time_text, :period_text,
                           :sd_period_text)

  def css_per_class(sec)
    if sec.type.match(/FREE/) || sec.name.match(/LUNC-100/)
      return "free"
    elsif sec.type.match(/SUPERDOUBLE/)
        return "per" + sec.sd_period_text
    else
      return "per" + sec.period_text.gsub(/^(\d).*/, '\1')
    end
  end

  def shorten_name(name)
    out = ""
    pieces = name.split(' ')
    len = pieces.length
    pieces.each_with_index do |s, i|
      if i+1 != len
        out += s[0] + '.'
      else
        out += ' ' + s
      end
    end
    out
  end

  def pref_name_form(person)
    out = person.full_name
    if person.first_name != person.pref_name && !person.pref_name.nil? && !person.pref_name.match(/^[[:space:]]+$/)
      out += " (#{person.pref_name})"
    end
    out
  end

  # TODO: Refactor!
  def create_schedule_view(stu)
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
    @schedule
  end
end
