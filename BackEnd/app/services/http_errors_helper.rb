class HttpErrorsHelper

    def self.handle_http_errors(response)
      #this function is used to return to the controller the errors of an
      #external API
      
      case response.code
        when 400
          {status: :bad_request, error: 'Bad Request' }
        when 401
          { status: :unauthorized, error: 'Unauthorized' } 
        when 500..599
          { status: :internal_server_error, error: 'Internal Server Error' }
        else
          { status: :unprocessable_entity, error: 'Unknown Error' }
        end     
      end

    def self.handle_pass_through_errors(result)
      #this function is used to return to the caller the errors of an internal API
      #remapping errors coming from an externa API
      #any other error coming from the internal API is caught at the application controller level and returned
      #as 500
       case result[:status]
        when :bad_request
          { error: result[:error] , status: :bad_request}
        when :unauthorized
          { error: result[:error] , status: :unauthorized}
        else
          { error: "Error calling external API" , status: :bad_gateway}
        end         
    end
end