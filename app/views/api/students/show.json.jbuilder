json.student do
  json.partial! 'students/student', locals: student: @student

  json.courses @student.sections do |section|
    json.id      section.id
    json.name    section.name
    json.teacher section.course.teacher
  end
end
