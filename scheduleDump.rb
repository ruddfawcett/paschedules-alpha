require 'pstore'
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

store = PStore.new(outfile)

def store.dump_model(klass)
  self[klass.table_name] = klass.all.to_a
end

store.transaction do
  store.dump_model(Person)
  store.dump_model(Course)
  store.dump_model(Supercourse)
  store.dump_model(Commitment)
  store.dump_model(Section)
  store.dump_model(StudentsCommitments)
  store.dump_model(StudentsSections)
end
