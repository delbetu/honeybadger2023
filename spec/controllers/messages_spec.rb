# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController do
  describe '#create' do
    let(:message_attributes) do
      {
        'id' => 1,
        'record_type' => 'Bounce',
        'type' => 'SpamNotification',
        'type_code' => 512,
        'name' => 'Spam notification',
        'tag' => '',
        'message_stream' => 'outbound',
        'description' => "The message was delivered,
          but was either blocked by the user,
          or classified as spam, bulk mail, or had rejected content.",
        'email' => 'zaphod@example.com',
        'from' => 'notifications@honeybadger.io',
        'bounced_at' => '2023-02-27T21:41:30Z'
      }
    end

    subject(:post_create) { post :create, params: message_attributes, as: :json }

    context 'when spam checker runs without error' do
      before do
        allow(SpamChecker).to receive(:process).and_return(double(success: true, message: 'message processed'))
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

    context 'when spam checker fails during execution' do
      before do
        allow(SpamChecker).to receive(:process).and_return(double(success: false,
                                                                  errors: ['Some error occurred. Try again later.']))
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
