module SectionsHelper
  def get_period(s)
    count = Array.new(10, 0)
    s.times.split(" ").each do |t|
      period = TIMES[t.to_i][2]
      next if !period.match(/^\d$/)
      count[period.to_i] += 1
    end
    result = count.index(count.max)
    suffices = %w(th st nd rd th th th th th th)
    return result.to_s + suffices[result % 10]
  end
end
