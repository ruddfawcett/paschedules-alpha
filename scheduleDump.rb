require File.expand_path("config/environment.rb")

outfile = ARGV.pop
if outfile.nil?
  puts "Usage: #{__FILE__} <outfile>" 
  exit(-1)
end

if File.exist?(outfile)
  puts "Warning: #{outfile} exists. Delete?"
  case gets.strip.downcase
  when "y", "yes"
    FileUtils.rm(outfile)
  else
    exit(-1)
  end
end

@store = {}

def dump_model(klass)
  @store[klass.table_name] = klass.all.to_a
end

dump_model(Person)
dump_model(Course)
dump_model(Supercourse)
dump_model(Commitment)
dump_model(Section)
dump_model(StudentsCommitments)
dump_model(StudentsSections)

File.open(outfile, 'w') do |file|
  Marshal.dump(@store, file)
end
