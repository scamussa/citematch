class Paper
    attr_reader :author_id
    attr_reader :paper_id
    attr_reader :title
    attr_reader :year
    attr_reader :other_authors
    attr_reader :doi
    attr_reader :citation_count
    attr_accessor :tldr

    def initialize(authorid,paperId,title,year,otherAuthors,doi,citationCount,tldr)
        @author_id = authorid
        @paper_id = paperId
        @title = title
        @year = year
        @other_authors = otherAuthors
        @doi = doi
        @citation_count = citationCount
        @tldr = tldr

        validate
    end

    def validate

        if FuncHelper.nil_or_empty_string?(@author_id)
            raise ArgumentError, "Author Id cannot be nil or empty"
        end

        if FuncHelper.nil_or_empty_string?(@paper_id)
            raise ArgumentError, "Paper Id cannot be nil or empty"
        end 

        if @title.nil?
            raise ArgumentError, "Title cannot be nil"
        end 

        if FuncHelper.nil_or_less_zero?(@year)
            raise ArgumentError, "Year cannot be nil or less than zero"
        end  

        if FuncHelper.nil_or_less_zero?(@citation_count)
            raise ArgumentError, "Citation Count cannot be nil or less to 0"
        end 

        if @doi.nil?
            raise ArgumentError, "doi cannot be nil"
        end

        if @other_authors.nil?
            raise ArgumentError, "Other Authors cannot be nil"
        end  

        if @tldr.nil?
            raise ArgumentError, "Tdlr cannot be nil"
        end  

    end




      def self.from_array_hash(authorId,data)

      #create paper list from the response of the extenal API
      #in case data creates an invalid paper it is not inserted in 
      #the array
        papers = []

        data.each do |pap|
          begin
            paper = from_hash_single(authorId,pap)
            papers<< paper
          rescue => e
            #in case of an invalid paper simple do nothing, skip the object
          end  
        end
        papers
      end

      def self.from_hash_single(authorId,data) 

        paper_id = data["paperId"] || ""
        title = data["title"] || ""
        year =  data["year"] || 0

        begin
            authors = data["authors"].map{|auth| auth["name"]}.join(", ")
        rescue => e
            authors = ""
        end 
        
        begin
            doi = data["externalIds"]["DOI"] || ""
        rescue => e
            doi = ""
        end

        citation_count = data["citationCount"] || 0

        begin
            tldr = data["tldr"]["text"] || ""
        rescue => e
            tldr = "" 
        end
        
        paper = Paper.new(
          authorId,
          paper_id,
          title,
          year, 
          authors,        
          doi,
          citation_count,
          tldr
        )
        paper
      end       
    

end