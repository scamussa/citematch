require 'rails_helper'

RSpec.describe "Authors API", type: :request do
  describe "Test API Response" do
    
    let(:keycloak_url) { 'http://localhost:9090/realms/cit-realm/protocol/openid-connect/token' }
    let(:client_id) { 'cit-client' }
    let(:client_secret) { ENV['KEYCLOACK_CLIENT_SECRET'] }
    let(:username) { 'cit-user-1' }
    let(:password) { 'cit-user-1' }
  
    let(:token) do
      response = HTTParty.post(keycloak_url, body: {
        grant_type: 'password',
        client_id: client_id,
        client_secret: client_secret,
        username: username,
        password: password
      })
      JSON.parse(response.body)['access_token']
    rescue HTTParty::Error => e
      puts "HTTParty Error: #{e.message}"
      nil
    end

    let(:headers) { { "Authorization" => "Bearer #{token}" } }

    context "when the API is called" do
      it "It returns a valid response" do
        puts token
        get "/author/search", params: { query: "camussa" }, headers: headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["Authors"]["total"]).to eq(5)
        expect(json_response["Authors"]["data"]).to be_an(Array)
        expect(json_response["Authors"]["data"].size).to eq(5)    
        json_response["Authors"]["data"].each do |author|
            expect(author["name"]).to include("Camussa")
        end        
      end
    end
  end
end
