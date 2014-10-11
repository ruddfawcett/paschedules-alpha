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
  stalks[stalker] ||= Hash.new(0)
  stalks[stalker][stalkee] += 1
end
sorted = stalks.sort_by{|k, v| v.max_by{|k, v| v}[1]}.reverse

sorted.first(50).each do |s|
  max = s[1].max_by{|k, v| v}
  puts "#{s[0].ljust(30)} #{max[0].ljust(30)} #{max[1]}"
end
