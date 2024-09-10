require 'rails_helper'

RSpec.describe "Authors API", type: :request do
  describe "Test API authentication" do
    
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


    context "when the token is valid" do
      it "calls the API and returns a 200 status" do
        puts token
        get "/author/search", params: { query: "camussa" }, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the token is invalid or not provided" do
      it "returns a 401 status" do
        get "/author/search", params: { query: "camussa" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
