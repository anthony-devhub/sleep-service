require 'rails_helper'

RSpec.describe 'Sleep Records API', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let(:user_id) { SecureRandom.uuid }
  let(:valid_user_response) { { 'id' => user_id, 'name' => 'Anthony' } }

  describe 'POST /api/v1/sleep_records' do
    context 'when the user does not exist' do
      before do
        allow(UserClient).to receive(:find).with(user_id).and_return(nil)
      end

      it 'returns 404 with user not found' do
        post '/api/v1/sleep_records', params: { user_id: user_id }
        expect(response.status).to eq(404)
        expect(json['message']).to eq('User not found')
      end
    end

    context 'when the user has not clocked out yet' do
      before do
        allow(UserClient).to receive(:find).with(user_id).and_return(valid_user_response)
        create(:sleep_record, user_id: user_id, clock_in: 2.hours.ago, clock_out: nil, duration: nil)
      end

      it 'returns 404 with error message' do
        post '/api/v1/sleep_records', params: { user_id: user_id }
        expect(response.status).to eq(404)
        expect(json['message']).to eq("User hasn't clocked out yet")
      end
    end

    context 'when the user is valid and not clocked in' do
      before do
        allow(UserClient).to receive(:find).with(user_id).and_return(valid_user_response)
      end

      it 'creates a new sleep record and returns all records ordered' do
        # Existing record to test ordering
        create(:sleep_record, user_id: user_id, clock_in: 3.days.ago, clock_out: 1.day.ago)

        post '/api/v1/sleep_records', params: { user_id: user_id }

        expect(response.status).to eq(200)

        body = json
        expect(body['message']).to eq('Clocked in successfully')
        expect(body['data']).to be_an(Array)

        latest_record = body['data'].first
        expect(latest_record['user_id']).to eq(user_id)
        expect(latest_record['clock_in']).not_to be_nil
        expect(latest_record['clock_out']).to be_nil
      end
    end
  end

  describe 'PUT /api/v1/sleep_records/:user_id' do
    let(:path) { "/api/v1/sleep_records/#{user_id}" }
    before do
      allow(UserClient).to receive(:find).with(user_id).and_return(valid_user_response)
    end

    context 'when no user is found' do
      before { allow(UserClient).to receive(:find).with(user_id).and_return(nil) }

      it 'returns 404' do
        put path
        expect(response).to have_http_status(404)
        expect(json['message']).to eq('User not found')
      end
    end

    context 'when no active sleep session exists' do
      it 'returns 422' do
        put path
        expect(response).to have_http_status(422)
        expect(json['message']).to eq('No active sleep session found')
      end
    end

    context 'when clock out is successful' do
      let!(:record) do
        SleepRecord.create!(
          user_id: user_id,
          clock_in: 2.hours.ago,
          clock_out: nil
        )
      end

      it 'updates the record and returns success' do
        freeze_time do
          put path
          expect(response).to have_http_status(200)
          expect(json['message']).to eq('Clocked out successfully')

          record.reload
          expect(record.clock_out).not_to be_nil
          expect(record.duration).to be_within(5).of(2.hours.to_i)
        end
      end
    end
  end

  describe 'GET /api/v1/sleep_records/friends' do
    let(:path) { '/api/v1/sleep_records/friends' }
    let(:followed_user_id) { SecureRandom.uuid }
    let(:followed_users) do
      [
        { 'id' => followed_user_id, 'name' => 'Friend One' }
      ]
    end

    before do
      allow(UserClient).to receive(:find).with(user_id).and_return(valid_user_response)
      allow(UserClient).to receive(:following).with(user_id).and_return(followed_users)
    end

    context 'when user is not found' do
      before { allow(UserClient).to receive(:find).with(user_id).and_return(nil) }

      it 'returns 404' do
        get path, params: { user_id: user_id }
        expect(response).to have_http_status(404)
        expect(json['message']).to eq('User not found')
      end
    end

    context 'when user has no followings' do
      before { allow(UserClient).to receive(:following).with(user_id).and_return([]) }

      it 'returns empty records' do
        get path, params: { user_id: user_id }
        expect(response).to have_http_status(200)
        expect(json['message']).to eq('No followed users.')
        expect(json['data']).to eq([])
      end
    end

    context 'when there are sleep records for followings' do
      let!(:record) do
        SleepRecord.create!(
          user_id: followed_user_id,
          clock_in: 10.hours.ago,
          clock_out: 2.hours.ago,
          duration: 8.hours.to_i
        )
      end

      before do
        allow(SleepRecordEnricher).to receive(:call).and_call_original
      end

      it 'returns sorted records' do
        get path, params: { user_id: user_id }
        expect(response).to have_http_status(200)
        expect(json['message']).to eq('Successfully fetched sleep records!')
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['user_id']).to eq(followed_user_id)
      end
    end
  end

end
