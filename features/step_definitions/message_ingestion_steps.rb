require 'net/imap'
When(/^I ingest messages$/) do
  @subject = Ingestion::Message.new
  expect(@subject.instance_variable_get(:@email_connection)).to be nil
  @subject.ingest
end

Given(/^There are no messages$/) do
  reset_email_server
  refresh_status
  expect(Ingestion::Message.all.length).to be 0
  expect(@ingested_status['MESSAGES']).to be 0
  expect(@inbox_status['MESSAGES']).to be > 0
end

Then(/^I have a connection to the e-mail server$/) do
  expect(@subject.instance_variable_get(:@email_connection).disconnected?).to be false
end

Then(/^I add a message to the database$/) do
  expect(Ingestion::Message.all.length).to be > 0
end

Then(/^The message is stored in the ingested folder on the email server$/) do
  refresh_status
  expect(@ingested_status['MESSAGES']).to be > 0
  expect(@inbox_status['MESSAGES']).to be 0
end

Then(/^The message object is saved with an image attachment$/) do
  message = Ingestion::Message.first
  expect(message.attachments.length).to be > 0
  expect(message.attachments[0][:type]).to eq('IMAGE/JPEG')
end

def refresh_status
  @inbox_status = @test_imap.status('INBOX', ['MESSAGES'])
  @ingested_status = @test_imap.status('INGESTED', ['MESSAGES'])
end

def reset_email_server
  @test_imap = Net::IMAP.new(ENV['HOME_SLICE_TEST_MSG_SERVER'], ssl: true)
  @test_imap.login(ENV['HOME_SLICE_TEST_MSG_USERNAME'], ENV['HOME_SLICE_TEST_MSG_PASSWORD'])
  return unless @test_imap.list('INGESTED', '*').present?
  @test_imap.select('INGESTED')
  @test_imap.search(%w(SINCE 1-Jan-1970)).reverse_each do |message_id|
    @test_imap.copy(message_id, 'INBOX')
    @test_imap.store(message_id, '+FLAGS', [:Deleted])
  end
  @test_imap.expunge
end
