require 'JWT'
class JwtHelper
    def self.valid_token?(token)
        begin
        decoded_token = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
        true
        rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
        false
        #true
        end
    end

    def self.public_key
        OpenSSL::PKey::RSA.new(File.read(Rails.root.join('path', 'keycloak_public_key.pem')))
    end
end