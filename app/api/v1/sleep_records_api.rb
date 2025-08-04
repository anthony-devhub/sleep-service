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

      desc 'Get sleep records of followed users from the past week, sorted by duration'
      params do
        requires :user_id, type: String, desc: 'ID of the user clocking in'
        optional :page, type: Integer, default: 1
        optional :limit, type: Integer, default: 20
      end
      get 'friends' do
        # Validate user from user service
        user = UserClient.find(params[:user_id])
        present_error('User not found', code: 404) unless user

        # Fetch following users and index them for easy lookup
        followed_users = UserClient.following(params[:user_id])
        return present_paginated_success([], Pagy.new(count: 0, page: 1), "No followed users.") if followed_users.empty?

        cache_key = [
          params[:user_id],
          params[:page],
          params[:limit]
        ].map(&:to_s).join('-')

        # Cache paginated + filtered results for 5 minutes
        data = Rails.cache.fetch("sleep-records:friends:#{cache_key}", expires_in: 5.minutes) do
          followed_user_ids = followed_users.map { |u| u['id'] }
          indexed_users     = followed_users.index_by { |u| u['id'] }

          # Query sleep records from the last 7 days with clock_out present
          sleep_records = SleepRecord
                            .where(user_id: followed_user_ids)
                            .where('clock_in >= ?', 1.week.ago)
                            .where.not(clock_out: nil)
                            .order(duration: :desc)

          pagy, paginated_records = paginate(sleep_records, page: params[:page].to_i, limit: params[:limit].to_i)

          # Merge user names
          enriched_records = SleepRecordEnricher.call(paginated_records, indexed_users)
          { records: enriched_records, pagy: pagy }
        end
        present_paginated_success(data[:records], data[:pagy], "Successfully fetched sleep records!")
      end
    end
  end
end