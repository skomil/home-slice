require 'rails_helper'

describe Ingestion::EmailIngestable do
  let(:class_with_email_ingestable) do
    Class.new do
      include Ingestion::EmailIngestable
    end
  end

  subject { class_with_email_ingestable.new }

  before do
    @imap = double('imap')
    allow(Net::IMAP).to receive(:new).and_return(@imap)
    allow(@imap).to receive(:login)
    allow(@imap).to receive(:search).and_return(%w(a b))
    allow(@imap).to receive(:select)
    allow(@imap).to receive(:disconnected?)
    allow(@imap).to receive(:expunge)
    allow(@imap).to receive(:create)
    subject.instance_variable_set(:@email_connection, @imap)
    @object = subject
  end

  describe 'ingest' do
    before do
      allow(subject).to receive(:capture_message)
      allow(subject).to receive(:list_or_create_ingestion_mailbox)
    end
    it 'should have iterated in reverse' do
      subject.ingest
      expect(subject.instance_variable_get(:@current_message_id)).to eq 'a'
    end
    it 'should call expunge' do
      expect(@imap).to receive(:expunge)
      subject.ingest
    end
  end

  describe 'open_connection' do
    it 'connects to an email server' do
      expect(@imap).to receive(:login)
      subject.open_connection
    end
  end

  describe 'list_or_create_ingestion_mailbox' do
    it 'should return if ingestion mailbox is created' do
      allow(@imap).to receive(:list).with('INGESTED', '*').and_return('MAILBOX')
      expect(@imap).to_not receive(:create)
      subject.list_or_create_ingestion_mailbox
    end
    it 'should create a mailbox if ingestion mailbox is needed' do
      allow(@imap).to receive(:list).with('INGESTED', '*').and_return(nil)
      expect(@imap).to receive(:create)
      subject.list_or_create_ingestion_mailbox
    end
  end
end
