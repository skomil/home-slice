module Ingestion
  # This module is used to connect to e-mail servers and save messages to the message
  # MongoDB message store. @ingested_item is a represents the MongoDB message that is being imported.
  module EmailIngestable
    # Ingest connects to the e-mail server and adds any messages that are not stored
    def ingest
      if !@email_connection.present? || @email_connection.disconnected?
        open_connection
      end
      list_or_create_ingestion_mailbox
      @email_connection.select('INBOX')
      @email_connection.search(%w(SINCE 1-Jan-1970)).reverse_each do |message_id|
        @current_message_id = message_id
        capture_message
      end
      @email_connection.expunge
    end

    # Open a connection to the e-mail server
    def open_connection
      @email_connection = Net::IMAP.new(ENV['HOME_SLICE_MSG_SERVER'], ssl: true)
      @email_connection.login(ENV['HOME_SLICE_MSG_USERNAME'], ENV['HOME_SLICE_MSG_PASSWORD'])
    end

    # Create an ingested mailbox if one is not present
    def list_or_create_ingestion_mailbox
      return if @email_connection.list('INGESTED', '*').present?
      @email_connection.create('INGESTED')
    end

    # processes a message and adds it to mongodb
    def capture_message
      @current_message = @email_connection.fetch(@current_message_id, %w(ENVELOPE BODY UID)).first
      message = @current_message.attr
      @ingested_item = Message.find_or_create_by(message_uid: message['UID'])
      envelope = message['ENVELOPE']
      @ingested_item.date = DateTime.parse(envelope.date).utc
      @ingested_item.subject = envelope.subject
      parse_message_body
      persist_message
    end

    # parses the body of a message into data for mongodb
    def parse_message_body
      if @current_message.attr['BODY'].media_type == 'MULTIPART'
        @current_message.attr['BODY'].parts.each_with_index do |part, index|
          @ingested_item.attachments = []
          parse_multipart(part, index)
        end
      else
        @ingested_item.message = @current_message.attr['BODY'].text
      end
    end

    # parses multipart attachments in messages
    def parse_multipart(part, index)
      multipart_selector = "BODY[#{index + 1}]"
      multipart = @email_connection.fetch(@current_message_id, multipart_selector)
      multipart_body = multipart.first.attr[multipart_selector]
      case part.media_type
      when 'TEXT' then @ingested_item.message = multipart_body
      when 'MULTIPART' then @ingested_item.message = multipart_body
      else
        type = "#{part.media_type}/#{part.subtype}"
        attachment = { type: type, encoding: part.encoding, contents: multipart_body }
        @ingested_item.attachments << attachment
      end
    end

    # saves message and updates location
    def persist_message
      @ingested_item.save!
      Rails.logger.info "Saving message uid: #{@ingested_item.message_uid}"
      @email_connection.copy(@current_message_id, 'INGESTED')
      @email_connection.store(@current_message_id, '+FLAGS', [:Seen, :Deleted])
      # reset local variables
      @current_message_id = nil
      @ingested_item = nil
    end
  end
end
