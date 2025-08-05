require 'rails_helper'

RSpec.describe UserClient do
  let(:base_url) { ENV.fetch('USER_SERVICE_URL') }
  let(:user_id) { "123" }
  before do
    UserClient.base_uri(base_url)
  end

  describe ".find" do
    let(:url) { "#{base_url}/api/v1/users/#{user_id}" }

    it "returns parsed data on success" do
      stub_request(:get, url)
        .to_return(
          status: 200,
          body: { data: { id: user_id, name: "Test" } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = described_class.find(user_id)
      expect(result).to eq({ "id" => user_id, "name" => "Test" })
    end

    it "returns nil on failure (e.g., 404)" do
      stub_request(:get, url).to_return(status: 404)

      result = described_class.find(user_id)
      expect(result).to be_nil
    end

    it "returns nil on timeout" do
      stub_request(:get, url).to_timeout

      result = described_class.find(user_id)
      expect(result).to be_nil
    end

    it "returns nil on standard error" do
      stub_request(:get, url).to_raise(StandardError.new("Unexpected boom"))

      result = described_class.find(user_id)
      expect(result).to be_nil
    end    
  end

  describe ".following" do
    let(:url) { "#{base_url}/api/v1/users/#{user_id}/following" }

    it "returns parsed data on success" do
      stub_request(:get, url)
        .to_return(
          status: 200,
          body: { data: [{ id: "456", name: "Follower" }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = described_class.following(user_id)
      expect(result).to eq([{ "id" => "456", "name" => "Follower" }])
    end
  end
end
