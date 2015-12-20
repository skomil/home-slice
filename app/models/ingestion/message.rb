require 'net/imap'
module Ingestion
  # Message is used to store e-mail messages retrieved from a service.
  # The purpose of this class is to hold all of the data for a message
  # and to handle sync with the e-mail server. Ingested messages are marked
  # as read by the e-mail server
  class Message
    # Ingest connects to the e-mail server and adds any messages that are not stored
    def ingest
      if !@email_connection.present? || @email_connection.disconnected?
        open_connection
      end
      true
    end

    private

    # Open a connection to the e-mail server
    def open_connection
      @email_connection = Net::IMAP.new(ENV['HOME_SLICE_MSG_SERVER'], ssl: true)
      @email_connection.login(ENV['HOME_SLICE_MSG_USERNAME'], ENV['HOME_SLICE_MSG_PASSWORD'])
    end
  end
end
