require 'net/imap'
module Ingestion
  # Message is used to store e-mail messages retrieved from a service.
  # The purpose of this class is to hold all of the data for a message
  # and to handle sync with the e-mail server. Ingested messages are marked
  # as read by the e-mail server
  class Message
    include Mongoid::Document
    include Ingestion::EmailIngestable
    field :message_uid, type: String
    field :date, type: DateTime
    field :subject, type: String
    field :message, type: String
    field :attachments, type: Array
    index({ message_uid: 1 }, unique: 'true', name: 'message_uid_index')
  end
end
