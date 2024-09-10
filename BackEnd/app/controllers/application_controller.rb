class ApplicationController < ActionController::API
    rescue_from StandardError, with: :handle_standard_error

    private
  
    def handle_standard_error(exception)
      render json: { error: 'Internal server error' }, status: :internal_server_error
      puts e
    end    
end
