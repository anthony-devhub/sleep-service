module V1
  class SleepRecordsApi < Grape::API
    helpers GlobalHelpers
    resource :sleep_records do
      
      desc 'Clock in (start sleeping)'
      params do
        requires :user_id, type: String, desc: 'ID of the user clocking in'
      end
      post do
        # Validate user from user-service
        user = UserClient.find(params[:user_id])
        present_error('User not found', code: 404) unless user

        # If user has clocked in, display validation
        record = SleepRecord.where(user_id: user['id'], clock_out: nil).order(created_at: :desc).first
        present_error("User hasn't clocked out yet", code: 404) if record

        # Create the sleep record
        record = SleepRecord.create!(user_id: params[:user_id], clock_in: Time.current)

        present_success(record,'Clocked in successfully')
      end

      desc 'Clock out (end sleeping)'
      params do
        requires :user_id, type: String, desc: 'ID of the user clocking in'
      end
      put ':user_id' do
        # Validate user from user-service
        user = UserClient.find(params[:user_id])
        present_error('User not found', code: 404) unless user

        # If user has clocked in, display validation
        record = SleepRecord.where(user_id: user['id'], clock_out: nil).order(created_at: :desc).first
        present_error('No active sleep session found', code: 422) unless record

        record.update!(
          clock_out: Time.current,
          duration: (Time.current - record.clock_in).to_i
        )
        present_success(record,'Clocked out successfully')
      end

      desc 'Fetch all records'
      get do
        # Example stubbed return
        [
          { id: 1, user_id: 42, clocked_in_at: Time.now },
          { id: 2, user_id: 7, clocked_in_at: Time.now - 6.hours }
        ]
      end
    end
  end
end