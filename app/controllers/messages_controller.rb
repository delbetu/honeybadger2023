# frozen_string_literal: true

# Receives messages and delegates to spam checker.
class MessagesController < ApplicationController
  # POST /messages
  def create
    result = SpamChecker.process(message_params)

    if result.success
      render json: { status: 'success', message: 'message processed' }, status: :created
    else
      render json: { status: 'error', message: result.errors.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def message_params
    params.permit(
      :record_type, :message_type, :type_code,
      :name, :tag, :message_stream,
      :description, :email, :from, :bounced_at
    )
  end
end
