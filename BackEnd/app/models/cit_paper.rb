class CitPaper
    attr_reader :paper_id
    attr_reader :citation_id
    attr_reader :doi
    attr_accessor :title
    attr_accessor :authors
    attr_reader :year
    attr_accessor :is_scholar_citation
    attr_accessor :is_open_citation
    attr_accessor :can_be_added_to_scholar

    def initialize(paperId,citationId,doi,title,authors, year)
        @paper_id = paperId
        @citation_id = citationId
        @doi = doi
        @title = title
        @authors = authors
        @year = year
        @is_scholar_citation = "no"
        @is_open_citation = "no"
        @can_be_added_to_scholar ="no"
        validate
    end

    def validate
        if FuncHelper.nil_or_empty_string?(@paper_id)
            raise ArgumentError, "Paper Id cannot be nil or empty"
        end  

        if FuncHelper.nil_or_empty_string?(@citation_id)
            raise ArgumentError, "Citation Id cannot be nil or empty"
        end   

        if @title.nil?
            raise ArgumentError, "Title cannot be nil"
        end 

        if FuncHelper.nil_or_less_zero?(@year)
            raise ArgumentError, "Year cannot be nil or less than zero"
        end 

        if @doi.nil?
            raise ArgumentError, "doi cannot be nil"
        end

        if @authors.nil?
            raise ArgumentError, "Authors cannot be nil"
        end
    end

    def self.from_array_hash_scholar(paperId,data)

        citations = []

        #crerate a citation from data coming from scholar API
        #in case data creates an invalid citation it is not inserted in 
        #the array
        data.each do |citation|

          begin
            citation_Id = citation["citingPaper"]["paperId"] || ""
          rescue => e
            citation_Id = ""
          end

          if citation["citingPaper"] && citation["citingPaper"]["externalIds"]
            doi = "doi:" + (citation["citingPaper"]["externalIds"]["DOI"] || "")
          else
            doi = ""
          end
          begin
            title = citation["citingPaper"]["title"] || ""
          rescue => e
            title = ""
          end
          begin
            year = citation["citingPaper"]["year"] || 0
          rescue => e
            year = ""
          end
          other_authors = (citation["citingPaper"] && citation["citingPaper"]["authors"] || []).map { |auth| auth["name"] }.join(", ")

          begin
            citation_to_insert = CitPaper.new(
                                    paperId,
                                    citation_Id,
                                    doi,
                                    title,
                                    other_authors,
                                    year

                                  )
            
            citations<<citation_to_insert
          rescue => e
            #do nothing
          end
        end
        citations
    end

    def self.from_array_hash_open(paperId,data)

         #crerate a citation from data coming from open citation API
        #in case data creates an invalid citation it is not inserted in 
        #the array     
        citations = []

        data.each do |citation|
          citation_id = citation["oci"] || ""
          doi = "doi:"+extract_doi(citation["citing"])
          year = extract_year(citation["creation"])

          begin
            if (!doi.empty?)
                citation_to_insert = CitPaper.new(
                                        paperId,
                                        citation_id,
                                        doi,
                                        "not defined",
                                        "not defined",
                                        year

                                    )
                citations << citation_to_insert
            end
          rescue => e
            puts e
          end  
        end     
        citations      
    end

    def self.extract_doi(text)
      #Estrae il campo doi
        match = text.match(/doi:([^\s]+)/)
        match ? match[1] : ""
    end

    def self.extract_year(creation_date)
        # Estrae l'anno da una data nel formato 'YYYY-MM-DD' o 'YYYY'

        match_data = creation_date.match(/^(\d{4})/)
        match_data ? match_data[1].to_i : 0

    end 

end