require 'net/http'
require 'json'
require 'uri'
require 'httparty'

class AuthorService

    def get_authors_by_name(page,query)
   
      limit = 10
      offset = (page.to_i-1)*limit
      field ="authorId,name,paperCount,citationCount,homepage,url"

       query_encoded = URI.encode_www_form_component(query)
       url = URI("https://api.semanticscholar.org/graph/v1/author/search?query=#{query_encoded}&limit=#{limit}&fields=#{field}&offset=#{offset}") 
       headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }        
       response = HTTParty.get(url,headers: headers)
       case response.code
       when 200
         data_array = response.parsed_response["data"]
         author_response = Author.from_hash_array(data_array).sort_by { |author| -author.paper_count }
         total_pages =get_number_of_pages(response.parsed_response["total"],limit)
        {
          Authors: {
            total: response.parsed_response["total"],
            page: page,
            total_pages: total_pages,
            data: author_response,
            },
          status: :ok
        }
      else
        HttpErrorsHelper.handle_http_errors(response)
      end
    end

    def get_publications_by_author(authorId,page)
      limit = 10
      offset = (page.to_i-1)*limit
      field ="paperId,title,year,authors,externalIds,citationCount"   

      url = URI("https://api.semanticscholar.org/graph/v1/author/#{authorId}/papers?limit=#{limit}&fields=#{field}&offset=#{offset}") 
      headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }        
       response = HTTParty.get(url,headers: headers)

      case response.code
      when 200
        papers = Paper.from_array_hash(authorId,response.parsed_response["data"])
        {
          Papers: {
            page: page,
            data: papers,
            },
          status: :ok
        }
      else
        HttpErrorsHelper.handle_http_errors(response)
      end
    end

    def get_author_by_id(authorId)

      field ="authorId,name,paperCount,citationCount,homepage,url" 

      url = URI("https://api.semanticscholar.org/graph/v1/author/#{authorId}?fields=#{field}") 

      headers = {
        "x-api-key" => ENV['SCHOLAR_API_KEY']
      }       
       response = HTTParty.get(url,headers: headers)
      case response.code
      when 200
        data_array = response.parsed_response
        author_response = Author.from_hash_single(data_array)
       {
         Author: author_response,       
         status: :ok
       }
      else
        HttpErrorsHelper.handle_http_errors(response)
      end
    end

    def get_number_of_pages(total,pagesize)
      quotient, remainder = total.divmod(pagesize)
      if remainder > 0
        quotient +=1
      end
      quotient
    end
end