module CommitmentsHelper
  def commitment_string(c)
    str = c.name + ": " + c.title
    if !c.teacher_name.nil?
      str += " - " + c.teacher_name
    end
    return str
  end
end
