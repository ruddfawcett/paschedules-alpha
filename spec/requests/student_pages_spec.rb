require 'spec_helper'

describe "Student pages" do
  Student.all.each do |s|
    it "#{s.full_name} should render" do
      visit student_path(s)
      expect(page).to have_content(s.full_name)
    end
  end
end
