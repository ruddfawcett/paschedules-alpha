module StudentsHelper
  
  def css_per_class(arr)
    if arr[3].match(/FREE/) || arr[0].match(/LUNC-100/)
      return "free"
    else
      return "per" + arr[5].gsub(/^(\d).*/, '\1')
    end
  end
end
