person, file = ARGV.shift(2)
unless person && file 
  puts "Usage: #{__FILE__} <email> <mapped log file>"
  exit 1
end

logs = File.read(file).split("\n")
logs.map!{|x| x.split}
logs.select!{|x| x[1] == person}
logs.reject!{|x| x[0] == x[1]}

stalkers = logs.each_with_object(Hash.new(0)){|p, hsh| hsh[p] += 1}

stalkers = stalkers.sort_by{|k, v| v}.reverse

stalkers.each do |s, c|
  puts "#{s[0].ljust(30)} #{c}"
end
