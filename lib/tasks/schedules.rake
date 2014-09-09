namespace :schedules do
  desc "Parse the PA Online Directory"
  task parseDirectory: :environment do
    begin
      USERNAME = readLogin[0]
      PASSWORD = readLogin[1]
      logInfo "Starting to parse Directory..."
      browser = Watir::Browser.new :firefox, profile: 'schedules'

      browser.goto('https://portal.vpn.andover.edu/Login/Login')
      browser.text_field(id: 'userName').set(USERNAME)
      browser.text_field(id: 'password').set(PASSWORD)
      browser.button(id: 'Login').click
      browser.link(text: 'Phillips Academy online Directory').click
      #Watir::Wait.until { browser.text.include? "Advanced.." } # lolwut
      frame = browser.iframe.iframe # They changed it for some reason...
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
          department = t.css("div.x-grid3-col-departmentNumber").text
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
                               first_name: firstName, email: email, department: department)
          person.pref_name = prefName unless prefName.match(/^[[:space:]]+$/) # The way the directory is formatted, blank
          person.save                                             # fields consist of just spaces
        end
        flag = frame.buttons[2].visible?
        if flag
          frame.buttons[2].click
          Watir::Wait.until { !frame.html.gsub(/\[.+\]/, '').include? Teacher.last.email } # Because the page uses AJAX/something similar
        end                    
      end
      browser.iframe.link(text: 'Students').click
      Watir::Wait.until { browser.iframe.iframes[1].html.include? "Grad Year" }
      frame = browser.iframe.iframes[1]
      flag = frame.buttons[2].visible?
      while flag do             # Not very DRY, basically same as above
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
          person.pref_name = prefName unless prefName.match(/^[[:space:]]+$/)
          person.save
        end
        flag = frame.buttons[2].visible?
        if flag
          frame.buttons[2].click
          Watir::Wait.until { !frame.html.gsub(/\[.+\]/, '').include? Student.last.email }
        end
      end
      logInfo "Directory parsing completed successfully"
    ensure
      browser.close
    end
  end
  desc "Parse the IDs. Parse directory BEFORE this!"
  task parseIds: :environment do
    begin
      USERNAME = readLogin[0]
      PASSWORD = readLogin[1]
      logInfo "Starting to parse IDs..."
      browser = Watir::Browser.new :firefox, profile: 'schedules'

      browser.goto('https://panet.andover.edu/webapps/portal/frameset.jsp')
      browser.iframes[1].text_field(name: 'user_id').set(USERNAME)
      browser.iframes[1].text_field(name: 'password').set(PASSWORD)
      browser.iframes[1].button.click
      browser.iframes[1].link(text: 'Schedule Search').click
      browser.window(title: 'Blackboard Learn').close
      #STUID = browser.url.sub(/.+stuid=([0-9]{7}).+/, '\1') #This will make it wait till the page loads
      STUID = "0483825"
      #browser.link(text: "Search").click

      Student.all.each do |stu| # Iterate through all students, search by name, give them an ID
        next unless stu.pa_id.nil? #If they already have an ID then skip it
        browser.text_field(name: 'lname').set(stu.last_name)
        browser.text_field(name: 'fname').set(stu.first_name)
        browser.button.click
        browser.text =~ /(\d+) matches found/
        if $1 == "0"
          logError "No Match for student #{stu.full_name}"
          next
        elsif $1 == "1"
          browser.link(text: browser.tables[1].to_a.last[1]).href =~ /stuid=(\d{7})/
          stu.pa_id = $1
          stu.save
        else
          logWarn "Multi Match with person #{stu.full_name}"
          next # Currently schedules are down...
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
      logInfo "ID parsing completed successfully."
    ensure
      browser.close # No longer #Commented out for debugging purposes
    end
  end

  desc "Add Extra People due to PA's database inconsistencies"
  task addExceptions: :environment do
    Teacher.create # Add a teacher with nil everything for lunch courses
    Teacher.create(full_name: "Kristin Bair O'Keeffe", email: 'kbairokeeffe@andover.edu', first_name: 'Kristin',   last_name: "Bair O'Keeffe",   department: 'English') # 'Director of Publications'
    Teacher.create(full_name: 'Kathryn J. McQuade',    email: 'kmcquade@andover.edu',     first_name: 'Kathryn',   last_name: 'McQuade',         department: 'English') #  but teaches ENGL-200
  end

  desc "Parse the Schedules. Parse IDs BEFORE this!"
  task parseSchedules: :environment do
    begin
      USERNAME = readLogin[0]
      PASSWORD = readLogin[1]
      logInfo "Starting to parse schedules..."

      browser = Watir::Browser.new :firefox, profile: 'schedules'

      browser.goto('https://panet.andover.edu/webapps/portal/frameset.jsp')
      browser.iframes[1].text_field(name: 'user_id').set(USERNAME)
      browser.iframes[1].text_field(name: 'password').set(PASSWORD)
      browser.iframes[1].button.click
      browser.iframes[1].link(text: 'My Schedule').click
      browser.window(title: 'Blackboard Learn').close
      STUID = browser.url.sub(/.+stuid=([0-9]{7}).+/, '\1') #This will make it wait till the page loads
      Student.all.each do |stu|
        # puts stu.full_name
        if stu.pa_id.nil?
          logError "No Student ID for #{stu.full_name}"
          next
        end
        browser.goto("https://colwizlive.andover.edu/cgi-bin/wwiz.exe/wwiz.asp?" \
                     "wwizmstr=WEB.STU.SCHED1.SUBR&stuid=#{stu.pa_id}&uid=#{STUID}&uou=student")

        doc = Nokogiri::HTML(browser.html) # Upgraded with Nokogiri
        resultsArray = []
        unexcused = doc.xpath("//table//tbody//tr[1]//td[3]//font[2]").text.gsub(/[[:space:]]/, '').to_i
        stu.unexcused = unexcused
        for i in 4..14
          tmpArr = []
          doc.xpath("//table//tbody//tr[#{i}]").text.split("\n").each do |s|
            s.gsub!(/^[[:space:]]*(.*?)[[:space:]]*$/, '\1') # Because Ruby currently has a bug where string#strip
            tmpArr << s unless s.empty? || s == "A"          # doesn't support Unicode spaces
          end
          resultsArray << tmpArr
        end

        resultsArray.each do |arr|
          next if arr[0].nil? || arr[0].empty? || arr[0].match(/PROJ/) || arr[0].match(/MUSC-909/) || arr[0].match(/MUSC-910/)
          secName = arr[0].strip
          secTitle = arr[1].strip
          teacherName = arr[2].strip
          if teacherName.match(/^\d+:\d+/) # If there isn't a teacher and this is a time
            teacherName = nil
          end
          if secName.match(/^ATH/) || secName.match(/^WD/) 
            commitment = Commitment.where(name: secName, title: secTitle, teacher_name: teacherName).first_or_create
            stu.commitments << commitment
          else
            time = arr[3].strip
            room = arr[4].strip
            courseName = secName.gsub(/(.+)-.*/, '\1')
            finalTeacher = nil
            if teacherName == "Department"
              finalTeacher = Teacher.find_by(full_name: nil)
            elsif teacherName == "D. Figarella-Zawil" # Inconsistency in PA's databases...imagine that
              finalTeacher = Teacher.find_by(full_name: "Diana F. Zawil")
            elsif teacherName == "K. Doba"
              finalTeacher = Teacher.find_by(full_name: "Khiem DoBa")
            else
              teacherName.gsub!(/(.+), .+/, '\1') # Get rid of a suffix (e.g. John Smith, III)
              teacher = Teacher.where(last_name: teacherName.split('.').last.strip)

              if teacher.length == 0
                logError "No teachers for section #{secName} for student #{stu.full_name}"
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
              logError "Nil Teacher for section #{secName} for student #{stu.full_name}"
            end

            supercourse = Supercourse.where(name: courseName, title: secTitle).first_or_create
            course = Course.where(teacher_id: finalTeacher.id, supercourse_id: supercourse.id).first_or_create
            section = Section.where(name: secName, course: course, room: room).first_or_create
            stu.sections << section
          end
        end
        stu.save
        # At this point, we have the students, what courses they are taking, and what students
        # are in what sections. The next part parses the student's schedule to get the time
        # during which each section meets

        boolvar = false          # If the we already know the times for all the student's
        stu.sections.each do |s| # sections, then don't waste time getting their schedule
          if s.times.nil?
            boolvar = true
            break
          end
        end
        next unless boolvar
        browser.link(text: "Schedule").click

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
          next if course.empty? || course.match(/^ATH-/) || course.match(/PROJ/)
          if newHash[course].nil?
            newHash[course] = period
          else
            newHash[course] += " " + period
          end
        end
        newHash.each do |course, times|
          section = stu.sections.where('name LIKE ?', "%#{course}%").take
          if section.nil?
            logError "Can't find section #{course}"
          end
          next unless section.times.nil? # If we have the time info from another student, dont rewrite it
          section.times = times
          section.save
        end
      end
      logInfo "Schedule parsing completed successfully."
    ensure
      browser.close # No longer #Commented out for debugging purposes
    end
  end

  desc "Remove students with no student ID from the database"
  task purgeNilIDs: :environment do 
    Student.all.each do |s|
      if s.pa_id.nil?
        logInfo "Removing #{s.full_name} from database"
        s.destroy
      end
    end
  end

  desc "Remove students with blank schedules from the database"
  task purgeBlankSchedules: :environment do
    Student.all.each do |s|
      if s.sections.count == 0
        logInfo "Removing #{s.full_name} from database"
        s.destroy
      end
    end
  end
  
  desc "Convert sections with nil times to commitments"
  task convertToCommitments: :environment do
    Section.where(times: nil).each do |s|
      comm = Commitment.create(teacher_name: s.course.teacher.full_name, title: s.course.supercourse.title, name: s.name)
      logInfo "Creating commitment from section #{s.name}"
      comm.students << s.students
      if s.course.supercourse.courses.count == 1
        logInfo "Destroying supercourse #{s.course.supercourse.name}"
        s.course.supercourse.destroy
      end
      if s.course.sections.count == 1
        logInfo "Destroying course #{s.course.supercourse.name}"
        s.course.destroy
      end
      logInfo "Destroying section #{s.name}"
      s.destroy
    end
  end

  desc "Reset the User counter to the latest user"
  task updateUserCounter: :environment do
    id = User.last.id
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH #{id + 1}")
  end
end

def logInfo(str)
  str = getTimeString + "INFO: " + str
  Rails.logger.info str
  puts str
end

def logError(str)
  str = getTimeString + "ERROR: " + str
  Rails.logger.error str
  puts str
end

def logWarn(str)
  str = getTimeString + "WARNING: " +str
  Rails.logger.warn str
  puts str
end

def getTimeString
  return "[" + Time.now.strftime("%x - %X") + "] "
end

def readLogin
  File.open("login_info", "r") do |file|
    return [file.gets.strip, file.gets.strip]
  end
end
