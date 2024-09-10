require 'net/http'
require 'json'
require 'uri'
require 'httparty'

class PaperService

    def get_semantic_scholar_citations_by_paper(paperId, page)

      limit = 100
      offset = 0
      field ="paperId,title,year,authors,externalIds" 
      citations_array = [] 
      has_error = false

      while !offset.nil?
        url = URI("https://api.semanticscholar.org/graph/v1/paper/#{paperId}/citations?limit=#{limit}&fields=#{field}&offset=#{offset}") 
       headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }       
       response = HTTParty.get(url,headers: headers)

        case response.code 
        when 200
          citations = CitPaper.from_array_hash_scholar(paperId,response.parsed_response["data"])
          citations_array.concat(citations)
          offset = response["next"] rescue nil
        else
          offset = nil
          has_error = true
        end         
      end
      
      has_error ? nil : citations_array
    end

    def get_open_citation_citations_by_paper(paperId)
      url = URI("https://opencitations.net/index/api/v2/citations/#{paperId}")
      response = HTTParty.get(url)
      has_error = nil
      case response.code   
      when 200
        CitPaper.from_array_hash_open(paperId,response.parsed_response)
      else
        nil    
      end
    end

    def get_title_authors_from_open(paperId)
      begin
        url = URI("https://opencitations.net/meta/api/v1/metadata/#{paperId}")
      rescue => e
        return ["no title available","no authors avalaible"] 
      end
      puts url
      response = HTTParty.get(url)
      case response.code   
      when 200
        data = response.parsed_response[0]
        title = data && data["title"] || "no title available"
        authors = data && data["author"] || "no authors avalaible"
        cleaned_authors = authors.gsub(/\s*\[.*?\]/, '')
        cleaned_authors = cleaned_authors.split(';').map(&:strip).join(', ')
        [title,cleaned_authors]
      else
        ["no title available","no authors avalaible"]         
      end

    end

    def is_publication_in_scholar!(paperId)
      begin
        url = URI("https://api.semanticscholar.org/graph/v1/paper/#{paperId}")
      rescue => e
        return false
      end

      headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }       
       response = HTTParty.get(url,headers: headers)

      case response.code   
      when 200
        true  
      else
        puts url
        puts response.code
        false
      end 
    end 

    def get_paper_by_id(paperId)
      field ="paperId,title,year,authors,externalIds,tldr,citationCount"

      url = URI("https://api.semanticscholar.org/graph/v1/paper/#{paperId}?fields=#{field}") 

      headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }       
       response = HTTParty.get(url,headers: headers)
       
      case response.code
      when 200
        data_array = response.parsed_response
        author_response = Paper.from_hash_single("n/d",data_array)
       {
         Paper: author_response,       
         status: :ok
       }
      else
        HttpErrorsHelper.handle_http_errors(response)
      end   
    end
end
