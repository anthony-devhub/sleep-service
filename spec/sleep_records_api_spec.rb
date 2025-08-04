require 'rails_helper'

RSpec.describe 'Sleep Records API', type: :request do
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
end
