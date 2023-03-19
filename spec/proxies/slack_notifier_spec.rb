# frozen_string_literal: true

require 'rails_helper'

describe SlackNotifier do
  subject(:notifier) { described_class.new }
  let(:message) { 'MESSAGE FOO' }
  let(:stub_api_call) do
    stub_request(:post, %r{https://hooks.slack.com/services/.*})
      .with(
        body: { text: message }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Host' => 'hooks.slack.com'
        }
      )
  end

  context 'when slack API works OK' do
    before do
      stub_api_call.to_return(status: 200, body: '', headers: {})
    end

    it 'does not fail' do
      notifier.notify_spam(message)
    end
  end

  context 'when slack API rejects connection' do
    before do
      stub_api_call.to_return(status: 404)
    end
    it 'raises an error' do
      expect do
        notifier.notify_spam(message)
      end.to raise_error(RuntimeError, 'Slack notification failed')
    end
  end
end
