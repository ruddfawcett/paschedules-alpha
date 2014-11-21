json.schedule do
  json.partial! 'students/student', locals: student: @student
  
  json.schedule @days do |d|
    json.partial! 'students/schedule_day', locals: day: d
  end
end
