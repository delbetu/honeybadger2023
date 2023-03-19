# frozen_string_literal: true

# Wrapper around slack 3rd party API
class SlackNotifier
  def initialize
    @webhook_url = ENV.fetch('SLACK_INCOMMING_WEBHOOK_URL')
  end

  def notify_spam(message)
    response = Net::HTTP.post(
      URI(webhook_url),
      { text: message }.to_json, 'Content-Type' => 'application/json'
    )

    raise 'Slack notification failed' unless response.is_a?(Net::HTTPSuccess)
  end

  private

  attr_reader :webhook_url
end
