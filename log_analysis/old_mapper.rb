require 'zlib'
require_relative '../config/environment.rb'
# 3 ID sets: 8/26, 9/7, 9/10

# 8/26 set

logs = Dir.glob("paschedules-logs/33950/**/*.gz*").each_with_object({}){|x, hsh| (hsh[Date.parse(x).to_s] ||= []) << x}

first_batch = logs.select{|x| Date.parse(x).between? Date.parse("2014-08-01"), Date.parse("2014-09-07")}
second_batch = logs.select{|x| Date.parse(x).between? Date.parse("2014-09-08"), Date.parse("2014-09-09")}
final_batch = logs.select{|x| Date.parse(x) >= Date.parse("2014-09-10")}

def process_batch(batch)
  batch.each do |k, v|
    v.each do |file|
      gz = Zlib::GzipReader.new(File.open(file))
      if file.include? "proxy"
        enum = gz.read.force_encoding("binary").split("\x00").each
      else
        enum = gz.read.each_line
      end

      enum.each do |l|
        next unless l.match /User (.+) requesting (.+)\./
        u1 = $1
        req = $2
        if req.match /\/students\/(\d+)/
          begin
            email = Student.find($1.to_i).email
            puts "#{u1} #{email}"
          rescue
            $stderr.puts "Could not find person for ID #{$1.to_i}"
          end
        end
      end
    end
  end
end

system("ruby ../scheduleRestore.rb https://paschedules-archive.s3.amazonaws.com/base_ids-08_26_2014")
process_batch(first_batch)

system("ruby ../scheduleRestore.rb https://paschedules-archive.s3.amazonaws.com/base_ids-09_07_2014")
process_batch(second_batch)

system("ruby ../scheduleRestore.rb https://paschedules-archive.s3.amazonaws.com/base_ids-09_10_2014")
process_batch(final_batch)
