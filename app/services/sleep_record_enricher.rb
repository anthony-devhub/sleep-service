module SleepRecordEnricher
  def self.call(records, user_index)
    records.map do |record|
      record.attributes.symbolize_keys.merge(name: user_index[record.user_id]&.dig("name"))
    end
  end
end
