json.array! day.periods do |per|
  json.times do 
    json.start per.start
    json.end per.end
  end
  
  json.section do
    json.partial! 'sections/section', locals: section: per.section
  end
  
  json.room per.room
  json.period per.period
end
