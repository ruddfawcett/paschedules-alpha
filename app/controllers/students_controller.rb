class StudentsController < ApplicationController
  def names
    names = []
    Student.all.each do |s|
      str = s.full_name
      if !s.pref_name.nil? && !s.pref_name.match(/^[[:space:]]+$/)
        str += " (" + s.pref_name + ")"
      end
      names << { "student" => str }
    end
    render json: names
  end
  
  def show
    id = params[:id]
    if id.match(/^\d{7}$/)
     @student = Student.find_by(pa_id: id)
    elsif id.match(/^\d+$/)
      @student = Student.find(id)
    else
      @student = Student.find_by(email: "#{id}@andover.edu")
    end
    if @student.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    respond_to do |format|
      format.png do
        gen_html = render_to_string :action => "show_png.html.erb", :layout => "png"
        @kit = IMGKit.new(gen_html, width: 600, height: 730)
        
        send_data(@kit.to_png, type: "image/png", disposition: "inline")
      end
      
      format.html
    end
  end  
end
