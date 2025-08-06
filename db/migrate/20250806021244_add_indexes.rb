class AddIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, [ :user_id, :clock_out ] # added because we have SleepRecord.where(user_id: user["id"], clock_out: nil)
    add_index :sleep_records, :clock_in                # added because we query .where(clock_in: 1.week.ago..)
    add_index :sleep_records, :duration                # added because we query .order(duration: :desc)
    add_index :sleep_records, :deleted_at              # added for future use of soft delete
  end
end
