# Postman Collection for SAST 8.7 API

* Import using the "import" button (duh)
* Specify three variables in your environment - server, username and password
* Run LoginAndGetToken. It'll autopopulate the new variable oauthtoken with the appropriate value
* Run other calls, in sequence or not, they will use the oauthtoken automatically and populate other values - see "test" tab

## Notes
* Collection version 2.1
* Postman v6.0+
* SAST 8.7+
