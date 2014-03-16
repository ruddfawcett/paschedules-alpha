module StudentsHelper
  
  def css_per_class(arr)
    if arr[3].match(/FREE/) || arr[0].match(/LUNC-100/)
      return "free"
    elsif arr[3].match(/SUPERDOUBLE/)
        return "per" + arr[6]
    else
      return "per" + arr[5].gsub(/^(\d).*/, '\1')
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
end
