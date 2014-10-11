ARGF.each_line do |l|
  next unless l.match(/User (.+) requesting \/students.+ \((.+)\)/)
  puts "#{$1} #{$2}"
end
