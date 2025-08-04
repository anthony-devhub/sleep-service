require 'rails_helper'

RSpec.describe SleepRecordEnricher do
  let(:user_id_1) { SecureRandom.uuid }
  let(:user_id_2) { SecureRandom.uuid }

  let(:record_1) { build(:sleep_record, user_id: user_id_1) }
  let(:record_2) { build(:sleep_record, user_id: user_id_2) }

  let(:indexed_users) do
    {
      user_id_1 => { "name" => "Anthony" },
      user_id_2 => { "name" => "Tommy" }
    }
  end

  it "adds name to each record from indexed_users" do
    result = described_class.call([record_1, record_2], indexed_users)
    expect(result).to include(
      hash_including(user_id: user_id_1, name: "Anthony"),
      hash_including(user_id: user_id_2, name: "Tommy")
    )
  end

  it "adds nil name when user info is missing" do
    result = described_class.call([record_1], {}) # No user info
    expect(result.first[:name]).to be_nil
  end
end
