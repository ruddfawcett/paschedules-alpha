class SearchController < ApplicationController
  def index
    str = params[:search]
    arr = str.split(' ')
    if str.match(/(\w+ (?:\w\.)? ?\w+) ?(?:\((\w+)\))?/) # Whee ugly regular expressions
      redirect_to Person.find_by(full_name: $1, pref_name: $2)
    end
    if arr.length > 4
      arr = arr.first(4)
      flash.now[:error] = "Too many search terms--your search has been truncated to \"#{arr[0]} #{arr[1]} #{arr[2]} #{arr[3]}\"."
    end

    @students = []
    arr.each_with_index do |a, idx|
      q = Person.search(full_name_or_first_name_or_last_name_or_pref_name_cont: a)
      if idx == 0
        @people = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @people = @people.select { |s| tmpArr.include? s }
      end
      q = nil
    end
    @people.uniq!
    @people.sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
    @count = @people.size
    @people = Kaminari.paginate_array(@people).page(params[:page]).per(20)
  end
end
