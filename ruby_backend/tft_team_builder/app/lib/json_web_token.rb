# frozen_string_literal: true

module JsonWebToken
  module_function

  def encode(payload, exp: 24.hours.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, "HS256")
  end

  def decode(token)
    body, = JWT.decode(token, secret_key, true, algorithm: "HS256")
    body.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def secret_key
    Rails.application.secret_key_base
  end
end
