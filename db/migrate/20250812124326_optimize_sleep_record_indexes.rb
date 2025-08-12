class OptimizeSleepRecordIndexes < ActiveRecord::Migration[8.0]
  def change
    ## Indexes have been redesigned for the specific query patterns,
    # with partial and ordered indexes to optimize for large datasets
    # while minimizing index size.

    # Drop redundant indexes (Postgres will prefer composites below)
    remove_index :sleep_records, :clock_in if index_exists?(:sleep_records, :clock_in)
    remove_index :sleep_records, :duration if index_exists?(:sleep_records, :duration)
    remove_index :sleep_records, :user_id if index_exists?(:sleep_records, :user_id)
    remove_index :sleep_records, [ :user_id, :clock_out ] if index_exists?(:sleep_records, [ :user_id, :clock_out ])

    # 1. For clock-in & clock-out validation (find latest active record quickly)
    add_index :sleep_records, [ :user_id, :created_at ], where: "clock_out IS NULL"

    # 2. For friends feed (last week, finished sleeps, sorted by duration desc)
    add_index :sleep_records, [ :user_id, :clock_in, :duration ], order: { duration: :desc }, where: "clock_out IS NOT NULL"
  end
end
