require 'open-uri'
require_relative "config/environment.rb"

infile = ARGV.pop
if infile.nil?
  puts "Usage: #{__FILE__} <infile>" 
  exit(-1)
end

# Works on both URLs and filepaths
open(infile) do |file|
  @store = Marshal.load(file)
end

def restore_model(klass)
  klass.destroy_all
  @store[klass.table_name].each do |x|
    klass.create(x.attributes)
  end
  ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
end

ActiveRecord::Base.transaction do
  restore_model(Person)
  restore_model(Course)
  restore_model(Supercourse)
  restore_model(Commitment)
  restore_model(Section)
  restore_model(StudentsCommitments)
  restore_model(StudentsSections)
end

