require 'json'
require 'recaptcha'
require 'base64'
require 'securerandom'
require 'openssl'

module Recaptcha
  module Token

    def self.secure_token
      private_key  =  Recaptcha.configuration.private_key
      raise RecaptchaError, "No private key specified." unless private_key

      stoken_json = {'session_id' => random_string(36), 'ts_ms' => (Time.now.utc.to_f * 1000).to_i}.to_json
      cipher = OpenSSL::Cipher::AES128.new(:ECB)
      private_key_digest = Digest::SHA1.digest(private_key)[0...16]

      cipher.encrypt
      cipher.key = private_key_digest
      encrypted_stoken = cipher.update(stoken_json) << cipher.final
      Base64.encode64(encrypted_stoken).tr('+/', '-_').gsub(/\=+\Z/, '').gsub("\n", '')
    end

  private

    def self.random_string(length)
      (0..length).to_a.map{|a| rand(length).to_s(length)}.join
    end

  end
end
