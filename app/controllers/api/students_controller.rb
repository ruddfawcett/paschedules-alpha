module Api
  class StudentsController < BaseController
    
    private
    
    def query_params
      params.permit(:id)
    end

  end
end
