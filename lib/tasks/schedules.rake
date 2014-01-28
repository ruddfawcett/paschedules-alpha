namespace :schedules do
  USERNAME = 'jherman'          # Maybe read from a file in the next version so I don't have
  PASSWORD = '******'           # to redact my password before pushing to git every time?
  desc "Parse the PA Online Directory"
  task parseDirectory: :environment do
    begin
      browser = Watir::Browser.new

      browser.goto('https://portal.vpn.andover.edu/Login/Login')
      browser.text_field(id: 'userName').set(USERNAME)
      browser.text_field(id: 'password').set(PASSWORD)
      browser.button(id: 'Login').click
      browser.link(text: 'Phillips Academy online Directory').click
      sleep 2
      frame = browser.frame.frame
      flag = frame.buttons[2].visible?
      while flag do
        # Watir-webdriver's table parsing abilities are very user-friendly, 
        # but too slow for the amount of data we have. Nokogiri is super fast
        doc = Nokogiri::HTML(frame.html)
        # puts doc.css('table.x-grid3-row-table').length
        doc.css('table.x-grid3-row-table').each do |t| # The CSS tags here are arbitrary and were obtained with
          email = t.css("a").text                      # Firefox's developer tools and trial/error with IRB
          fullName = t.css("div.x-grid3-col-cn").text
          prefName = t.css("div.x-grid3-col-middleName").text
          fullName =~ /(.+), (.+)/
          firstName = $2
          lastName = $1
          # middle = ""
          if firstName =~ /(.+) (\w)$/ # If they have a middle initial
            firstName = $1
            fullName = "#{firstName} #{$2}. #{lastName}"
          else
            fullName = "#{firstName} #{lastName}"
          end
          person = Teacher.new(full_name: fullName, last_name: lastName,
                               first_name: firstName, email: email)
          person.pref_name = prefName unless prefName.match(/ +/) # The way the directory is formatted, blank 
          person.save                                             # fields consist of just spaces
        end
        flag = frame.buttons[2].visible?
        frame.buttons[2].click if flag
        sleep 2 # Waiting a specified amount of time is really ugly; TODO: Find a better way
      end
      browser.frame.link(text: 'Students').click 
      sleep 3                                    
      frame = browser.frame.frames[1]
      flag = browser.frame.frames[1].buttons[2].visible?
      flag = frame.buttons[2].visible?                  
      while flag do
        doc = Nokogiri::HTML(frame.html)
        #puts doc.css('table.x-grid3-row-table').length
        doc.css('table.x-grid3-row-table').each do |t|
          email = t.css("a").text
          fullName = t.css("div.x-grid3-col-cn").text
          prefName = t.css("div.x-grid3-col-middleName").text
          gradYear = t.css('div.x-grid3-col-namescape-com-ExtensionString17').text
          cluster = t.css('div.x-grid3-col-namescape-com-ExtensionStrings11').text
          fullName =~ /(.+), (.+)/
          firstName = $2
          lastName = $1
          # middle = ""
          if firstName =~ /(.+) (\w)$/ 
            firstName = $1
            fullName = "#{ firstName } #{$2}. #{ lastName }"
          else
            fullName = "#{firstName} #{lastName}"
          end
          person = Student.new(full_name: fullName, last_name: lastName,
                               first_name: firstName, email: email,
                               cluster: cluster, grad_year: gradYear)
          person.pref_name = prefName unless prefName.match(/ +/)
          person.save
        end
        flag = frame.buttons[2].visible?
        frame.buttons[2].click if flag
        sleep 2
      end
    ensure
      browser.close
    end
  end
  desc "Parse the IDs. Parse directory BEFORE this!"
  task parseIds: :environment do
    begin
      browser = Watir::Browser.new

      browser.goto('https://panet.andover.edu/webapps/portal/frameset.jsp')
      browser.frames[1].text_field(name: 'user_id').set(USERNAME)
      browser.frames[1].text_field(name: 'password').set(PASSWORD)
      browser.frames[1].button.click
      browser.frames[1].link(text: 'My Schedule').click
      browser.window(title: 'Blackboard Learn').close
      STUID = browser.url.sub(/.+stuid=([0-9]{7}).+/, '\1') #This will make it wait till the page loads
      browser.link(text: "Search").click

      Student.all.each do |stu| # Iterate through all students, search by name, give them an ID
        next unless stu.pa_id.nil? #If they already have an ID then skip it
        browser.text_field(name: 'lname').set(stu.last_name)
        browser.text_field(name: 'fname').set(stu.first_name)
        browser.button.click
        browser.text =~ /(\d+) matches found/
        if $1 == "0"
          puts "ERROR: No Match for student #{stu.full_name}"
          next
        elsif $1 == "1"
          browser.link(text: browser.tables[1].to_a.last[1]).href =~ /stuid=(\d{7})/
          stu.pa_id = $1
          stu.save
        else                 
          puts "Multi Match with student #{stu.full_name}"
          browser.tables[1].to_a.last[1].split("\n").each do |s| # Visit each student's schedule, and
            next unless s.include?("Student")                    # check email addresses to assign the
            browser.link(text: s).click                          # correct ID to a student
            browser.tables[2].to_a[0][1] =~ /Student Email: (.+)/
            email = $1.strip
            browser.tables[2].to_a[1][0] =~ /Student ID#: (\d{7})/
            id = $1.strip
            s2 = Student.find_by(email: email)
            browser.back #Go back before the 'next' clause
            next unless s2.pa_id.nil?
            s2.pa_id = id
            s2.save
          end
        end
      end
    ensure
      #browser.close #Commented out for debugging purposes
    end
  end

  desc "Add Extra People due to PA's database inconsistencies"
  task addExceptions: :environment do
    Teacher.create # Add a teacher with nil everything for lunch courses
    Teacher.create(full_name: "Kathryn J. McQuade", first_name: "Kathryn", # Create this because, for some inexplicable reason,
                   last_name: "McQuade", email: "kmcquade@andover.edu")    # this person isn't in the Namescape rDirectory here
  end

  desc "Parse the Schedules. Parse IDs BEFORE this!"
  task parseSchedules: :environment do
    begin
      # require 'pp'
      browser = Watir::Browser.new

      browser.goto('https://panet.andover.edu/webapps/portal/frameset.jsp')
      browser.frames[1].text_field(name: 'user_id').set(USERNAME)
      browser.frames[1].text_field(name: 'password').set(PASSWORD)
      browser.frames[1].button.click
      browser.frames[1].link(text: 'My Schedule').click
      browser.window(title: 'Blackboard Learn').close
      STUID = browser.url.sub(/.+stuid=([0-9]{7}).+/, '\1') #This will make it wait till the page loads
      Student.all.each do |stu|
        if stu.pa_id.nil?
          Rails.logger.error "ERROR: No Student ID for #{stu.full_name}"
          next
        end
        browser.goto("https://colwizlive.andover.edu/cgi-bin/wwiz.exe/wwiz.asp?" \
                     "wwizmstr=WEB.STU.SCHED1.SUBR&stuid=#{stu.pa_id}&uid=#{STUID}&uou=student")
        
        doc = Nokogiri::HTML(browser.html) # Upgraded with Nokogiri
        resultsArray = []
        for i in 4..14
          tmpArr = []
          doc.xpath("//table//tbody//tr[#{i}]").text.split("\n").each do |s|
            s.gsub!(/^[[:space:]]*(.*?)[[:space:]]*$/, '\1') # Because Ruby currently has a bug where string#strip
            tmparr << s unless s.empty?                      # doesn't support Unicode spaces
          end
          resultsArray << tmpArr
        end
        require 'pp'

        #browser.tables[0].to_a.each_with_index do |arr, idx| # This tables function is a bit slow...
        resultsArray.each do |arr|
          next if arr[0].nil? || arr[0].empty? || arr[0].match(/^ATH-/) || arr[0].match(/WD-/) || # Ignore music lessons, work duty,
            arr[0].match(/MUSC-909/) || arr[0].match(/MUSC-910/) # || idx < 3        # and athletics
          pp arr
          secName = arr[0].strip
          secTitle = arr[1].strip
          teacherName = arr[2].strip
          time = arr[3].strip
          room = arr[4].strip
          courseName = secName.gsub(/(.+)-.*/, '\1')
          finalTeacher = nil
          if teacherName == "Department"
            finalTeacher = Teacher.find_by(full_name: nil)
          elsif teacherName == "D. Figarella-Zawil" # Inconsistency in PA's databases...imagine that
            finalTeacher = Teacher.find_by(full_name: "Diana F. Zawil")
          elsif teacherName == "K. Doba" # YAY MORE INCONSISTENCY!!!!
            finalTeacher = Teacher.find_by(full_name: "Khiem DoBa")
          else
            teacherName.gsub!(/(.+), .+/, '\1') # Get rid of a suffix (e.g. John Smith, III)
            teacher = Teacher.where(last_name: teacherName.split('.').last.strip)

            if teacher.length == 0
              Rails.logger.error "ERROR: No teachers for section #{secName} for student #{stu.full_name}"
            elsif teacher.length == 1
              finalTeacher = teacher.first
            else
              regex = teacherName.gsub('.', '.*')
              teacher.each do |t|                 
                if t.full_name.match(regex)
                  finalTeacher = t
                  break
                end
              end
            end
          end
          #pp finalTeacher
          if finalTeacher.nil?
            Rails.logger.error "ERROR: Nil Teacher for section #{secName} for student #{stu.full_name}"
          end
          # Commented out because I wrote this before knowing about first_or_create
          # course = Course.where(name: courseName, teacher_id: finalTeacher.id)
          # if course.length == 0
          #   course = Course.create(name: courseName, teacher_id: finalTeacher.id, title: secTitle)
          # elsif course.length == 1
          #   course = course.first
          # else
          #   Rails.logger.error "ERROR: Multiple courses with same name: #{courseName}"
          # end
          course = Course.where(name: courseName, teacher_id: finalTeacher.id, # Manually supply the ID because
                                title: secTitle).first_or_create               # it got screwed up with polymorphism
          # section = Section.where(course: course, name: secName)
          # if section.length == 0
          #   section = Section.create(name: secName, course: course, room: room)
          # elsif section.length == 1
          #   section = section.first
          # else
          #   Rails.logger.error "ERROR: Multiple sections with same name: #{secName}"
          # end
          section = Section.where(name: secName, course: course, room: room).first_or_create
          stu.sections << section
        end
        stu.save
        # At this point, we have the students, what courses they are taking, and what students
        # are in what sections. The next part parses the student's schedule to get the time
        # during which each section meets
        # Under Construction.......
        boolvar = false          # If the we already know the times for all the student's
        stu.sections.each do |s| # sections, then don't waste time getting their schedule
          if s.times.nil?
            boolvar = true
            break
          end
        end
        next unless boolvar
        browser.link(text: "Schedule").click
        
        # Watir's tables[]... function is really easy to use, but its horrendously slow
        # The following code takes adds about 4 seconds to runtime, which for 1200 students is 
        # unacceptable.  I may re-write this in Nokogiri if I can figure out how to. DONE: Nokogiri below
        
        # resultsHash = {         # Hooray for Emacs' multiple-cursors mode and iy-go-to-char...
        #   # Monday
        #   "0" => browser.tables[0][1].tables[1][1][0].text.split("\n")[2],   # 1
        #   "1" => browser.tables[0][1].tables[1][2][0].text.split("\n")[2],   # 2
        #   # Conference - [1][3][0]
        #   "2" => browser.tables[0][1].tables[1][4][0].text.split("\n")[2],   # 3
        #   "3" => browser.tables[0][1].tables[1][5][0].text.split("\n")[2],   # 4
        #   "4" => browser.tables[0][1].tables[1][6][0].text.split("\n")[2],   # 5
        #   "5" => browser.tables[0][1].tables[1][7][0].text.split("\n")[2],   # 6
        #   "6" => browser.tables[0][1].tables[1][8][0].text.split("\n")[2],   # 7
        #   "7" => browser.tables[0][1].tables[1][10][0].text.split("\n")[2],  # 9
        #   "8" => browser.tables[0][1].tables[1][11][0].text.split("\n")[2],  # 9e
        #   # Tuesday
        #   "9" => browser.tables[0][1].tables[1][1][1].text.split("\n")[2],   # 1
        #   "10" => browser.tables[0][1].tables[1][2][1].text.split("\n")[2],  # 2
        #   # Conference [1][3][1]
        #   "11" => browser.tables[0][1].tables[1][4][1].text.split("\n")[2],  # 3
        #   "12" => browser.tables[0][1].tables[1][5][1].text.split("\n")[2],  # 4
        #   "13" => browser.tables[0][1].tables[1][6][1].text.split("\n")[2],  # 5
        #   "14" => browser.tables[0][1].tables[1][7][1].text.split("\n")[2],  # 6
        #   "15" => browser.tables[0][1].tables[1][8][1].text.split("\n")[2],  # 7
        #   "16" => browser.tables[0][1].tables[1][10][1].text.split("\n")[2], # 9
        #   "17" => browser.tables[0][1].tables[1][11][1].text.split("\n")[2], # 9e
        #   # Wednesday
        #   "18" => browser.tables[0][1].tables[1][1][2].text.split("\n")[2],  # 1
        #   "19" => browser.tables[0][1].tables[1][2][2].text.split("\n")[2],  # 1e
        #   "20" => browser.tables[0][1].tables[1][3][2].text.split("\n")[2],  # 2e
        #   "21" => browser.tables[0][1].tables[1][4][2].text.split("\n")[2],  # 2
        #   # ASM [1][5][2]
        #   "22" => browser.tables[0][1].tables[1][6][2].text.split("\n")[2],  # 7
        #   "23" => browser.tables[0][1].tables[1][7][2].text.split("\n")[2],  # 7e
        #   # Thursday
        #   "24" => browser.tables[0][1].tables[1][2][3].text.split("\n")[2],  # 3e
        #   "25" => browser.tables[0][1].tables[1][3][3].text.split("\n")[2],  # 3
        #   # Conference [1][3][4]
        #   "26" => browser.tables[0][1].tables[1][5][3].text.split("\n")[2],  # 4
        #   "27" => browser.tables[0][1].tables[1][6][3].text.split("\n")[2],  # 4e
        #   "28" => browser.tables[0][1].tables[1][7][3].text.split("\n")[2],  # 5e
        #   "29" => browser.tables[0][1].tables[1][8][3].text.split("\n")[2],  # 5
        #   "30" => browser.tables[0][1].tables[1][9][2].text.split("\n")[2],  # 6
        #   "31" => browser.tables[0][1].tables[1][10][2].text.split("\n")[2],
        #   "32" => browser.tables[0][1].tables[1][12][0].text.split("\n")[2], # 9
        #   "33" => browser.tables[0][1].tables[1][13][0].text.split("\n")[2], # 9e
        #   # Friday
        #   "34" => browser.tables[0][1].tables[1][1][4].text.split("\n")[2],  # 1
        #   "35" => browser.tables[0][1].tables[1][2][4].text.split("\n")[2],  # 2
        #   # Advising [1][3][4]
        #   "36" => browser.tables[0][1].tables[1][4][4].text.split("\n")[2],  # 3
        #   "37" => browser.tables[0][1].tables[1][5][4].text.split("\n")[2],  # 4
        #   "38" => browser.tables[0][1].tables[1][6][4].text.split("\n")[2],  # 5
        #   "39" => browser.tables[0][1].tables[1][7][4].text.split("\n")[2],  # 6
        #   "40" => browser.tables[0][1].tables[1][8][4].text.split("\n")[2],  # 7
        #   "41" => browser.tables[0][1].tables[1][12][1].text.split("\n")[2], # 9
        #   "42" => browser.tables[0][1].tables[1][13][1].text.split("\n")[2]  # 9e
        # }
        doc = Nokogiri::HTML(browser.html) # Nokogiri = fast
        resultsHash = {
          # Monday
          "0" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[2]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 1
          "1" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 2
          # Conference
          "2" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[5]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 3
          "3" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[6]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 4
          "4" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[7]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 5
          "5" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[8]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 6
          "6" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[9]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 7
          "7" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[11]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 9
          "8" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[12]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 9e
          # Tuesday
          "9" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[2]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 1
          "10" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[3]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 2
          # Conference
          "11" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[5]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 3
          "12" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[6]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 4
          "13" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[7]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 5
          "14" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[8]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 6
          "15" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[9]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 7
          "16" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[11]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip, # 9
          "17" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[12]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip, # 9e
          # Wednesday
          "18" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[2]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 1
          "19" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[3]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 1e
          "20" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[4]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 2e
          "21" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[5]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 2
          # ASM
          "22" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[7]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 7
          "23" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[8]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 7e
          # Thursday
          "24" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[3]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 3e
          "25" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[4]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 3
          # Conference
          "26" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[6]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 4
          "27" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[7]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 4e
          "28" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[8]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 5e
          "29" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[9]//td[4]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 5
          "30" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[10]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 6
          "31" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[11]//td[3]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 6e
          "32" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[13]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 9
          "33" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[14]//td[1]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 9e
          # Friday
          "34" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[2]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 1
          "35" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[3]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 2
          # Advising 
          "36" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[5]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 3
          "37" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[6]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 4
          "38" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[7]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 5
          "39" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[8]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 6
          "40" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[9]//td[5]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,   # 7
          "41" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[13]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip,  # 9
          "42" => doc.xpath("//body//table[1]//tbody[1]//tr[2]//td[1]//table[1]//tbody[1]//tr[3]//td[1]//table[1]//tbody[1]//tr[14]//td[2]//b[2]//font[1]//font[1]").text.split("\n")[0].strip  # 9e
        }
        newHash = {}
        resultsHash.each do |period, course|
          next if course.empty? || course.match(/^ATH-/)
          if newHash[course].nil?
            newHash[course] = period
          else
            newHash[course] += " " + period
          end
        end
        newHash.each do |course, times|
          section = stu.sections.where('name LIKE ?', "%#{course}%").take
          if section.nil?
            Rails.logger.error "ERROR: Can't find section #{course}"
          end
          next unless section.times.nil?
          section.times = times
          section.save
        end
      end

    ensure
      # =>browser.close #Commented out for debugging purposes
    end
  end
end
