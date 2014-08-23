require 'pstore'
require 'pry'
require File.expand_path("config/environment.rb")

infile = ARGV.pop
if infile.nil?
  puts "Usage: #{__FILE__} <infile>" 
  exit(-1)
end

unless File.exist?(infile)
  puts "Error: Input file not found"
  exit(-1)
end

store = PStore.new(infile)

def store.restore_model(klass)
  klass.destroy_all
  self[klass.table_name].each do |x|
    klass.create(x.attributes)
  end
  ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
end

ActiveRecord::Base.transaction do
  store.transaction(true) do
    store.restore_model(Person)
    store.restore_model(Course)
    store.restore_model(Supercourse)
    store.restore_model(Commitment)
    store.restore_model(Section)
    store.restore_model(StudentsCommitments)
    store.restore_model(StudentsSections)
  end
end

