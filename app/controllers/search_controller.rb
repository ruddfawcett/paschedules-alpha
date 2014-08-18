class SearchController < ApplicationController
  def index
    str = params[:search]
    arr = str.split(' ')
    if str.match(/([a-zA-Z]+-\w+\/?\d?): \w+/) # if its a course
      sc = Supercourse.find_by(name: $1)
      if !sc.nil?
        redirect_to sc
        return
      end
    end
    if str.match(/(\S+ (?:\S\.)? ?\S+) ?(?:\((\S+)\))?/) # Whee ugly regular expressions
      p = Person.find_by(full_name: $1, pref_name: $2)
      if !p.nil?
        redirect_to p
        return
      end
    end
    if arr.length > 4
      arr = arr.first(4)
      flash.now[:error] = "Too many search terms--your search has been truncated to \"#{arr[0]} #{arr[1]} #{arr[2]} #{arr[3]}\"."
    end
    
    @students = []
    arr.each_with_index do |a, idx|
      q = Student.search(full_name_or_first_name_or_last_name_or_pref_name_cont: a)
      if idx == 0
        @students = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @students = @students.select { |s| tmpArr.include? s }
      end
      q = nil
    end
    @students = @students.to_a
    @students.uniq!
    @students.sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
    @students_count = @students.size
    @students = Kaminari.paginate_array(@students).page(params[:students_page]).per(20)

    @teachers = []
    arr.each_with_index do |a, idx|
      q = Teacher.search(full_name_or_first_name_or_last_name_or_pref_name_cont: a)
      if idx == 0
        @teachers = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @teachers = @teachers.select { |s| tmpArr.include? s }
      end
      q = nil
    end
    @teachers = @teachers.to_a
    @teachers.uniq!
    @teachers.sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
    @teachers_count = @teachers.size
    @teachers = Kaminari.paginate_array(@teachers).page(params[:teachers_page]).per(20)
    
    @courses = []
    arr.each_with_index do |a, idx|
      q = Supercourse.search(name_or_title_cont: a)
      if idx == 0
        @courses = q.result(distinct: true)
      else
        tmpArr = q.result(distinct: true)
        @courses = @courses.select { |s| tmpArr.include? s }
      end
      q = nil
    end
    @courses = @courses.to_a
    @courses.uniq!
    @courses.sort! { |a, b| a.name.downcase <=> b.name.downcase }
    @courses_count = @courses.size
    @courses = Kaminari.paginate_array(@courses).page(params[:courses_page]).per(20)
  end
end
