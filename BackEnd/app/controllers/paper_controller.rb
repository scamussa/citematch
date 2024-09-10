require 'net/http'
require 'json'
require 'uri'
require 'httparty'


class PaperController < ApplicationController

    before_action :authenticate_request!

    def get_citations_by_paper
        page = params[:page] || 1
        paper_id = params[:paper_id]
        paper_service = PaperService.new()
        result = nil
    
        scholar_cit = paper_service.get_semantic_scholar_citations_by_paper(paper_id, page)
        open_cit = paper_service.get_open_citation_citations_by_paper(paper_id)

        if (!scholar_cit.nil? && !open_cit.nil?)
            result = merge_citations(scholar_cit,open_cit)
            render json: result, status: :ok;    
        else
          render json: { error: "Error Calling External APIs" }, status: :bad_gateway
        end
    end

    def get_paper_by_Id
        paper_id = params[:paper_id]
        paper_service = PaperService.new()
        result = paper_service.get_paper_by_id(paper_id)
        case result[:status]
        when :ok
          render json: result, status: :ok
        else
          remap_status = HttpErrorsHelper.handle_pass_through_errors(result)
          render json: remap_status, status: remap_status[:status]  
        end     
      end
       

    def merge_citations(scholar_cit,open_cit)

        only_scholar = []
        only_open = []
        both_provider = []

        paper_service = PaperService.new()

        only_scholar = scholar_cit.select do |scit|
            open_cit.none? { |ocit| ocit.doi == scit.doi }
        end

        both_provider = scholar_cit.select do |scit|
            open_cit.any? { |ocit| ocit.doi == scit.doi }
        end  

        only_open = open_cit.select do |ocit|
            scholar_cit.none? { |scit| scit.doi == ocit.doi }
        end     
        
        only_scholar.each do |cit|
            cit.is_scholar_citation = "yes"
            cit.is_open_citation = "no"
            cit.can_be_added_to_scholar = "no"
        end
        both_provider.each do |cit|
            cit.is_scholar_citation = "yes"
            cit.is_open_citation = "yes"
            cit.can_be_added_to_scholar = "no"
        end

        only_open.each do |cit|
            cit.is_scholar_citation = "no"
            cit.is_open_citation = "yes"
            metadata = paper_service.get_title_authors_from_open(cit.doi)
            cit.title = metadata[0]
            cit.authors = metadata[1]
            sleep(0.2) 
            cit.can_be_added_to_scholar = paper_service.is_publication_in_scholar!(cit.doi) ? "yes" : "no"
        end

        only_open.sort_by {|cit| cit.year || Float::INFINITY} + 
        both_provider.sort_by {|cit| cit.year || Float::INFINITY} +
        only_scholar.sort_by {|cit| cit.year || Float::INFINITY}
        
      end   

      def authenticate_request!
        token = request.headers['Authorization']&.split(' ')&.last
        unless token && JwtHelper.valid_token?(token)
          render json: { error: 'Not Authorized' }, status: :unauthorized
        end
      end
end