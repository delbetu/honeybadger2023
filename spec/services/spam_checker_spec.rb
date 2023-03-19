# frozen_string_literal: true

require 'rails_helper'

# TODO: convert into a class
# just trying to understand its API on beforehand
SlackNotifier = Class.new do
  def notify_spam(message); end
end

describe SpamChecker do
  subject(:process_message) { described_class.new.process(message, notifier:) }
  let(:notifier) { instance_double(SlackNotifier, notify_spam: nil) }
  let(:not_spam_message) do
    {
      record_type: 'Bounce',
      message_stream: 'outbound',
      type: 'HardBounce',
      type_code: 1,
      name: 'Hard bounce',
      tag: 'Test',
      description: 'The server was unable to deliver your message (ex: unknown user, mailbox not found).',
      email: 'arthur@example.com',
      from: 'notifications@honeybadger.io',
      bounced_at: '2019-11-05T16:33:54.9070259Z'
    }
  end
  let(:spam_message) do
    {
      record_type: 'Bounce',
      type: 'SpamNotification',
      type_code: 512,
      name: 'Spam notification',
      tag: '',
      message_stream: 'outbound',
      description: 'The message was delivered, but was either blocked by the user, ' \
        'or classified as spam, bulk mail, or had rejected content.',
      email: 'zaphod@example.com',
      from: 'notifications@honeybadger.io',
      bounced_at: '2023-02-27T21:41:30Z'
    }
  end

  describe '#process' do
    context 'when message is spam' do
      let(:message) { spam_message }

      it 'notifies about it' do
        process_message
        expect(notifier).to have_received(:notify_spam).with(
          'Message to zaphod@example.com from notifications@honeybadger.io'\
          ' was detected as spam on Mon Feb 27 21:41:30 +00:00 2023'
        )
      end
    end

    context 'when message is NOT spam' do
      let(:message) { not_spam_message }

      it 'does NOT notifies about it' do
        process_message
        expect(notifier).not_to have_received(:notify_spam)
      end
    end

    context 'when everything goes well' do
      let(:message) { not_spam_message }
      it 'returns success and a human readable message' do
        is_expected.to have_attributes(
          success: true,
          message: 'Message processed successfully.'
        )
      end
    end

    context 'when some error occurs' do
      let(:message) { spam_message }
      before do
        allow(notifier).to receive(:notify_spam).and_raise('foo error')
      end
      it 'returns a list of humanized errors' do
        is_expected.to have_attributes(
          success: false,
          errors: ['Some error occurred. Try again later.']
        )
      end
    end
  end
end
