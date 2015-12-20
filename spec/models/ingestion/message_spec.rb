require 'rails_helper'

describe Ingestion::Message, type: :model do
  describe 'open_connection' do
    it 'connects to an email server' do
      subject = Ingestion::Message.new
      subject.instance_eval { open_connection }
      connection = subject.instance_variable_get(:@email_connection)
      expect(connection.disconnected?).to be_falsey
    end
  end

  describe 'ingest' do
    it 'should not have a connection before ingest is called' do
      expect(subject.instance_variable_get(:@email_connection)).to be_nil
    end

    it 'should have a connection after ingestion' do
      subject.ingest
      expect(subject.instance_variable_get(:@email_connection).disconnected?).to be_falsey
    end
  end
end
