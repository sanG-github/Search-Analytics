# frozen_string_literal: true

module CoreExtensions
  module Warden
    module JWTAuth
      module TokenDecoderCustom
        def call(token)
          JWT.decode(token,
                     decoding_secret || ENV.fetch('JWT_SECRET_KEY', nil),
                     true,
                     algorithm: algorithm,
                     verify_jti: true)[0]
        end
      end
    end
  end
end

Warden::JWTAuth::TokenDecoder.prepend(CoreExtensions::Warden::JWTAuth::TokenDecoderCustom)
