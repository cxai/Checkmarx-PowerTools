# Postman Collections

## Running

* Import using the "import" button (duh)
* Specify three variables in your environment - {{server}}, {{username}} and {{password}}
* Run LoginAndGetToken. It'll autopopulate the new variable {{oauthtoken}} with the appropriate value via the test tab script.
* Run other requests, in sequence or not. They will use the {{oauthtoken}} automatically and populate other values through the "test" script

## Notes
* Postman collection v2.1
* Postman v6.0+
* SAST 8.7+
