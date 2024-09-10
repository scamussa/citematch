class Author
  
    attr_reader :name
    attr_reader :author_id
    attr_reader :paper_count
    attr_reader :citation_count
    attr_reader :home_page
    attr_reader :url

    def initialize(name,authorId,papercount,citationcount,homepage,url)     
      @name = name
      @author_id = authorId
      @paper_count = papercount
      @citation_count = citationcount
      @home_page = homepage
      @url = url
      validate
    end

    def validate
      if FuncHelper.nil_or_empty_string?(@name)
        raise ArgumentError, "Name cannot be nil or empty"
      end

      if FuncHelper.nil_or_empty_string?(@author_id)
        raise ArgumentError, "Author Id cannot be nil or empty"
      end

      if @home_page.nil?
        raise ArgumentError, "Home Page cannot be nil"
      end

      if @home_page.nil?
        raise ArgumentError, "URL  cannot be nil"
      end

      if FuncHelper.nil_or_less_zero?(@paper_count)
        raise ArgumentError, "Paper Count cannot be nil or less to 0"
      end

      if FuncHelper.nil_or_less_zero?(@citation_count)
        raise ArgumentError, "Citation Count cannot be  nil or less to 0"
      end

    end

    def self.from_hash_array(data)

      #create an author list from the response of the extenal API
      #in case data creates an invalid author it is not inserted in 
      #the array
      authors = []
      data.each do |auth|
        begin
          author = from_hash_single(auth)
          authors<<author
        rescue => e
          #in case of an invalid author simple do nothing, skip the object 
        end
      end
      authors
    end   

    def self.from_hash_single(data)        
      Author.new(
          data["name"] || "",
          data["authorId"] || "",
          data["paperCount"] || 0,
          data["citationCount"] || 0,
          data["homepage"] || "",
          data["url"] || ""
        )
    end    
  end