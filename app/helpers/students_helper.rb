module StudentsHelper
  
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
end
