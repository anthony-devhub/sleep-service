class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :user_id, type: :uuid, null: false, index: true
      t.datetime :clock_in, null: false
      t.datetime :clock_out
      t.integer :duration
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
