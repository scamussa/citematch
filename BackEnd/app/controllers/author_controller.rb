require 'net/http'
require 'json'
require 'uri'
require 'httparty'


class AuthorController < ApplicationController

  before_action :authenticate_request!

  def get_authors_by_name

    page = params[:page] || 1
    query = params[:query]
    author_service = AuthorService.new()
    result = author_service.get_authors_by_name(page,query)

    case result[:status]
    when :ok
      render json: result, status: :ok
    else
      remap_status = HttpErrorsHelper.handle_pass_through_errors(result)
      render json: remap_status, status: remap_status[:status]  
    end   
  end

  def get_publications_by_author

    page = params[:page] || 1
    author_id = params[:author_id]
    author_service = AuthorService.new()
    result = author_service.get_publications_by_author(author_id, page)
    case result[:status]
    when :ok
      render json: result, status: :ok
    else
      remap_status = HttpErrorsHelper.handle_pass_through_errors(result)
      render json: remap_status, status: remap_status[:status]  
    end 
  end

  def get_author_by_Id

    author_id = params[:author_id]
    author_service = AuthorService.new()
    result = author_service.get_author_by_id(author_id)
    case result[:status]
    when :ok
      render json: result, status: :ok
    else
      remap_status = HttpErrorsHelper.handle_pass_through_errors(result)
      render json: remap_status, status: remap_status[:status]  
    end    
  end

  def authenticate_request!
    #Verify the bearer token using the public key used by keycloack
    #the public key is stored locally so no rountrip to keycloack is neceaary
    #also the expiry date of the token is verified

    token = request.headers['Authorization']&.split(' ')&.last
    unless token && JwtHelper.valid_token?(token)
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end

end
