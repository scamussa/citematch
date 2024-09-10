Rails.application.routes.draw do
  get '/author/search', to: 'author#get_authors_by_name'
  get '/author/:author_id/publication', to:'author#get_publications_by_author'
  get '/author/:author_id', to:'author#get_author_by_Id'
  get '/paper/:paper_id/citations', to:'paper#get_citations_by_paper', constraints: { paper_id: /.*/ }, as: 'paper_citations'
  get '/paper/:paper_id', to:'paper#get_paper_by_Id', constraints: { paper_id: /.*/ }
  get '/debug', to: 'author#debug'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html




end
