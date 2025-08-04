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

        # Create the sleep record
        record = SleepRecord.create!(user_id: params[:user_id], clock_in: Time.current)

        present_success(record,'Clocked in successfully')
      end

      desc 'Fetch all clock-ins'
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