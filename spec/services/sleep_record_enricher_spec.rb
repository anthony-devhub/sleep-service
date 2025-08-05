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

  describe ".call" do
    it "adds name and formatted duration_string" do
      record = build(:sleep_record, user_id: user_id_1, duration: 3665) # 1h 1m 5s
      result = described_class.call([record], indexed_users).first

      expect(result[:name]).to eq("Anthony")
      expect(result[:duration_string]).to eq("1 hour, 1 minute, 5 seconds")
    end

    it "returns nil name if user is missing" do
      record = build(:sleep_record, user_id: user_id_1)
      result = described_class.call([record], {}).first

      expect(result[:name]).to be_nil
    end

    it "returns nil duration_string if duration is 0" do
      record = build(:sleep_record, user_id: user_id_1, duration: 0)
      result = described_class.call([record], indexed_users).first

      expect(result[:duration_string]).to be_nil
    end
  end

  describe ".format_duration" do
    it "returns only seconds" do
      expect(described_class.format_duration(45)).to eq("45 seconds")
    end

    it "returns only minutes" do
      expect(described_class.format_duration(60)).to eq("1 minute")
    end

    it "returns only hours" do
      expect(described_class.format_duration(3600)).to eq("1 hour")
    end

    it "returns hours and minutes" do
      expect(described_class.format_duration(3660)).to eq("1 hour, 1 minute")
    end

    it "returns full formatted string with pluralization" do
      expect(described_class.format_duration(7325)).to eq("2 hours, 2 minutes, 5 seconds")
    end

    it "returns nil for negative duration" do
      expect(described_class.format_duration(-10)).to be_nil
    end

    it "returns nil for 0 duration" do
      expect(described_class.format_duration(0)).to be_nil
    end
  end
end
