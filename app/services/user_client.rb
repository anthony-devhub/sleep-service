class UserClient
  include HTTParty
  base_uri ENV.fetch('USER_SERVICE_URL')

  HEADERS = { 'Content-Type' => 'application/json' }

  def self.find(user_id)
    response = get("/api/v1/users/#{user_id}", headers: HEADERS)
    parse_response(response)
  end

  def self.following(user_id)
    response = get("/api/v1/users/#{user_id}/following", headers: HEADERS)
    parse_response(response)
  end

  def self.parse_response(response)
    return nil unless response.success?
    response.parsed_response["data"]
  end
end
