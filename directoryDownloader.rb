require 'watir-webdriver'
require 'nokogiri'
USERNAME = 'jherman'
PASSWORD = '********'

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
    doc = Nokogiri::HTML(frame.html) #Nokogiri is very fast
    puts doc.css('table.x-grid3-row-table').length
    doc.css('table.x-grid3-row-table').each do |t|
      email = t.css("a").text
      fullName = t.css("div.x-grid3-col-cn").text
      prefName = t.css("div.x-grid3-col-middleName").text
      puts "#{prefName}:#{fullName}:#{email}"
    end
    flag = frame.buttons[2].visible?
    frame.buttons[2].click if flag
    sleep 2
  end
  browser.frame.link(text: 'Students').click
  frame = browser.frame.frames[1]
  flag = browser.frame.frames[1].buttons[2].visible?
  flag = frame.buttons[2].visible?
  while flag do
    doc = Nokogiri::HTML(frame.html) #Nokogiri is very fast
    puts doc.css('table.x-grid3-row-table').length
    doc.css('table.x-grid3-row-table').each do |t|
      email = t.css("a").text
      fullName = t.css("div.x-grid3-col-cn").text
      prefName = t.css("div.x-grid3-col-middleName").text
      gradYear = t.css('div.x-grid3-col-namescape-com-ExtensionString17').text
      cluster = t.css('div.x-grid3-col-namescape-com-ExtensionStrings11').text
      puts "#{prefName}:#{fullName}:#{email}:#{gradYear}:#{cluster}"
    end
    flag = frame.buttons[2].visible?
    frame.buttons[2].click if flag
    sleep 2
  end  
ensure
  #browser.close #Commented out for debugging purposes
end
