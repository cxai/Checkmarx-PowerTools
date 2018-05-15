# Checkmarx automations through REST APIs

## Python - `scan-with-rest.py`
An example python script for creating new project, submitting three successive full scans and an OSA scan, by using a python library for the Checkmarx REST APIs.
Needs just a server name, user name and a password. The API library is in the CxREST folder.

Python 2.7 and 3.6, Linux and Windows, for Cx 8.6 and 8.7 APIs

### Windows setup
* Install Python [2.7](https://www.python.org/ftp/python/2.7.14/python-2.7.14.msi), [3.6](https://www.python.org/ftp/python/3.6.5/python-3.6.5.exe) or some newer version
* Download [pip](https://bootstrap.pypa.io/get-pip.py) if you do not have it. pip should be already installed if you are using Python 2 >=2.7.9 or Python 3 >=3.4 downloaded from python.org. Pip can be installed with `C:\Python27\python.exe get-pip.py`
* Install the *requests* module `pip install requests` or `C:\Python27\python.exe -m pip install requests`

## Curl - `scan-with-rest-curl.sh`
A sample REST Application for submitting a SAST scan using pure curl commands. Uploads a zip file for scanning on an existing project and waits for the scan to complete.
This script needs only curl, sed and awk for parsing.

## Powershell - `register-engine-with-rest-api.ps1`
An example how to use REST API's from Powershell to register an engine. Older cookie style login.
