FactoryBot.define do
  factory :sleep_record do
    user_id { SecureRandom.uuid }
    clock_in { Time.current }
    clock_out { clock_in + 8.hours }
    duration { (clock_out - clock_in).to_i }
  end
end
