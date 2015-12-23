When(/^I ingest messages$/) do
  @subject = Ingestion::Message.new
  expect(@subject.instance_variable_get(:@email_connection)).to be nil
  @subject.ingest
end

Then(/^I have a connection to the e-mail server$/) do
  expect(@subject.instance_variable_get(:@email_connection).disconnected?).to be false
end
