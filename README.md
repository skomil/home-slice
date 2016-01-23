### Home Slice Home Automation Server

#### Dependencies

Ruby/Bundler

Mongodb

#### Environment Variables

E-Mail Server: Security Camera and other systems that produce data and do not have an API are sent to an e-mail server
data from the e-mail server is collected and processed by the automation server The following variables are for
connection to this server
```sh
HOME_SLICE_MSG_SERVER={Imap Server Address}
HOME_SLICE_MSG_USERNAME={Imap Server Username}
HOME_SLICE_MSG_PASSWORD={Imap Server Password}

HOME_SLICE_TEST_MSG_SERVER={Imap Test Server Address}
HOME_SLICE_TEST_MSG_USERNAME={Imap Test Server Username}
HOME_SLICE_TEST_MSG_PASSWORD={Imap Test Server Password}
```
#### Contributing
Before committing run rake and ensure all tests pass
