Feature: Message Ingestion
   so that I can import messages

  Scenario: Ingest Messages
    Given There are no messages
    When I ingest messages
    Then I have a connection to the e-mail server
    Then I add a message to the database
    Then The message is stored in the ingested folder on the email server
    Then The message object is saved with an image attachment