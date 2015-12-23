Feature: Message Ingestion
   so that I can import messages

  Scenario: Ingest Messages
    When I ingest messages
    Then I have a connection to the e-mail server