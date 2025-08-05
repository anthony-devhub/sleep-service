class UserClient
  include HTTParty
  base_uri ENV.fetch("USER_SERVICE_URL")

  HEADERS = { "Content-Type" => "application/json" }

  # Set timeout and retry options
  default_timeout ENV.fetch("DEFAULT_TIMEOUT").to_i
  maintain_method_across_redirects true

  def self.find(user_id)
    with_rescue do
      response = get("/api/v1/users/#{user_id}", headers: HEADERS)
      parse_response(response)
    end
  end

  def self.following(user_id)
    with_rescue do
      response = get("/api/v1/users/#{user_id}/following", headers: HEADERS)
      parse_response(response)
    end
  end

  def self.parse_response(response)
    return nil unless response.success?
    response.parsed_response["data"]
  end

  def self.with_rescue
    yield
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.warn("[UserClient] Timeout: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("[UserClient] Unexpected error: #{e.message}")
    nil
  end
end
