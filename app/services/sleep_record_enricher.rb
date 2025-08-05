module SleepRecordEnricher
  def self.call(records, user_index)
    records.map do |record|
      attrs = record.attributes.symbolize_keys

      duration = attrs[:duration].to_i
      attrs[:name] = user_index[record.user_id]&.dig("name")
      attrs[:duration_string] = format_duration(duration)
      attrs
    end
  end

  def self.format_duration(seconds)
    return nil if seconds <= 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    secs = seconds % 60

    parts = []
    parts << "#{hours} #{'hour'.pluralize(hours)}" if hours > 0
    parts << "#{minutes} #{'minute'.pluralize(minutes)}" if minutes > 0
    parts << "#{secs} #{'second'.pluralize(secs)}" if secs > 0
    parts.join(", ")
  end
end
