require 'spec_helper'

describe "Authentication" do
  
  describe "login page" do
    subject { page }
    before { visit signin_path }
    it { should have_title('Sign In') }
  end

end
