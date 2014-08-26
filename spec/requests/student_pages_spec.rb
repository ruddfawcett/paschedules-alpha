require 'spec_helper'

describe "Student pages" do
  it "renders a student" do
    Student.all.each do |s|
      visit student_path(s)
      expect(page.status_code).to equal 200
      expect(page).to have_content(s.full_name)
    end
  end
end
