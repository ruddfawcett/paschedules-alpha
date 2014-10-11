file = ARGV.shift
unless file 
  puts "Usage: #{__FILE__} <mapped log file>"
  exit 1
end

logs = File.read(file).split("\n")
logs.map!{|x| x.split}
logs.reject!{|x| x[0] == x[1]}

stalks = {}
logs.each do |l|
  stalker = l[0]
  stalkee = l[1]
  stalks[stalkee] ||= []
  stalks[stalkee] << stalker
  stalks[stalkee].uniq!
end
sorted = stalks.sort_by{|k, v| v.length}.reverse

sorted.first(50).each do |s|
  puts "#{s.first} #{s[1].length}"
end
