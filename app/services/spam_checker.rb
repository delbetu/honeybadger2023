# frozen_string_literal: true

# Notifies in case the message is a spam
class SpamChecker
  def self.process(msg) = new.process(msg)

  Result = Struct.new(:success, :message, :errors)

  def process(message_hash, notifier: SlackNotifier.new)
    notifier.notify_spam(notification_message(message_hash)) if spam?(message_hash)

    Result.new(true, 'Message processed successfully.', [])
  rescue StandardError => e
    Rails.logger.error(e) # should report to error tracking service

    Result.new(false, '', ['Some error occurred. Try again later.'])
  end

  private

  def notification_message(message_hash) =
    "Message to #{email(message_hash)} from #{from(message_hash)} was detected as spam on #{bounced_at(message_hash)}"

  # fail if required attrs are not present
  def email(message_hash) = message_hash.fetch(:email)
  def message_type(message_hash) = message_hash.fetch(:type)
  def bounced_at(message_hash) = DateTime.parse(message_hash.fetch(:bounced_at)).strftime('%+')
  def from(message_hash) = message_hash.fetch(:from)

  def spam?(message_hash) = message_type(message_hash).casecmp?('spamnotification')
end
