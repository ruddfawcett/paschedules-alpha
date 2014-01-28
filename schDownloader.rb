require 'watir-webdriver'
require 'logger'

USERNAME = 'jherman'
PASSWORD = '*******'

begin
  browser = Watir::Browser.new

  browser.goto('https://panet.andover.edu/webapps/portal/frameset.jsp')
  browser.frames[1].text_field(name: 'user_id').set(USERNAME)
  browser.frames[1].text_field(name: 'password').set(PASSWORD)
  browser.frames[1].button.click
  browser.frames[1].link(text: 'My Schedule').click
  browser.window(title: 'Blackboard Learn').close
  STUID = browser.url.sub(/.+stuid=([0-9]{7}).+/, '\1') #This will make it wait till the page loads

  File.open("ids.txt").each do |line|
    puts "Downloading Schedule for ID #{line}"
    browser.goto("https://colwizlive.andover.edu/cgi-bin/wwiz.exe/wwiz.asp?" \
                 "wwizmstr=WEB.STU.SCHED1.SUBR&stuid=#{line}&uid=#{STUID}&uou=student")
    #stu = Student.new
    browser.tables[2].to_a.each do |arr|
      arr.each do |s|
        s =~ /(.+): (.+)/
        field = $1.strip
        val = $2.strip
        
        case field
        when 'Student Name'
          #stu.first_name = val.split(' ').first
          #stu.last_name = val.split(' ')[2].sub(/,/, '')
          #stu.full_name = val
          puts "First Name: " + val.split(' ').first
          puts "Last Name: " + val.split(' ')[2].sub(/,/, '')
          puts "Full Name: " + val
        when 'Student ID#'
          #stu.pa_id = val
          puts "pa_id: " + val
        when 'Class'
          #stu.class = val
          puts "Class: " + val
        when 'Cluster'
          #stu.cluster = val
          puts "Cluster: " + val
        when 'Dorm'
          val.sub!(/ \d+.*/, '')
          #stu.dorm = val
          puts "Dorm: " + val
        when 'Advisor'
          #This is more complicated for the student
          puts "Advisor: " + val
        end
      end
    end
    browser.tables[0].to_a.each_with_index do |arr, idx|
      next if arr[0] == " " || idx < 3
      secName = arr[0].strip
      secTitle = arr[1].strip
      teacher = arr[3].strip
      time = arr[4].strip
      room = arr[5].strip
      #Do database stuff......
      puts "Section #{secName}*#{secTitle}*#{teacher}*#{time}*#{room}"
    end
  end
ensure
  #browser.close #Commented out for debugging purposes
end
