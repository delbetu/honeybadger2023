# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/messages', type: :request do
  let(:message_attributes) do
    {
      "RecordType": 'Bounce',
      "Type": 'SpamNotification',
      "TypeCode": 512,
      "Name": 'Spam notification',
      "Tag": '',
      "MessageStream": 'outbound',
      "Description": 'The message was delivered, but was either blocked by the user, or classified as spam, bulk mail, or had rejected content.',
      "Email": 'zaphod@example.com',
      "From": 'notifications@honeybadger.io',
      "BouncedAt": '2023-02-27T21:41:30Z'
    }
  end
  let(:stub_api_call) do
    stub_request(:post, %r{https://hooks.slack.com/services/.*})
      .with(
        headers: {
          'Content-Type' => 'application/json',
          'Host' => 'hooks.slack.com'
        }
      )
  end
  subject(:post_create) { post messages_url, params: message_attributes, as: :json }

  describe 'POST /create' do
    context 'when runs without error' do
      before do
        stub_api_call.to_return(status: 200, body: '', headers: {})
      end
      it 'returns success' do
        post_create
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to match(
          'status' => 'success', 'message' => 'message processed'
        )
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when third party API fails' do
      before do
        stub_api_call.to_return(status: 500, body: '', headers: {})
      end
      it 'returns error' do
        post_create
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to match(
          'status' => 'error', 'message' => 'Some error occurred. Try again later.'
        )
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
