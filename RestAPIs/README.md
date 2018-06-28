# Checkmarx automations through the REST APIs

A set of scripts to interact with a Checkmarx server using Python, Powershell or Bash

## Python - `scan-with-rest.py`
An example python script for creating new project, submitting three successive full scans and an OSA scan, by using a python library for the Checkmarx REST APIs.
Needs just a server name, user name and a password. The API library is in the CxREST folder.

Python 2.7 and 3.6, both Linux and Windows. Tested on Checkmarx 8.6 and 8.7 APIs.

### Running the python script on Windows
* Install Python [2.7](https://www.python.org/ftp/python/2.7.14/python-2.7.14.msi), [3.6](https://www.python.org/ftp/python/3.6.5/python-3.6.5.exe) or some newer version
* Download [pip](https://bootstrap.pypa.io/get-pip.py) if you do not have it. pip should be already installed if you are using Python 2 >=2.7.9 or Python 3 >=3.4 downloaded from python.org. Pip can be installed with `C:\Python27\python.exe get-pip.py`
* Install the *requests* module `pip install requests` or `C:\Python27\python.exe -m pip install requests`

## Bash with curl - `scan-with-rest-curl.sh`
A sample REST Client for submitting a SAST scan using pure curl commands. Uploads a zip file for scanning on an existing project and then waits for the scan to complete.
This script uses `curl`, `sed` and `awk`.

## Powershell - `register-engine-with-rest-api.ps1`
An example of using REST APIs from Powershell. Registers a new engine with the manager. Uses older cookie style login.

## PostmanCollections
CxSAST REST collection for [Postman](https://www.getpostman.com/). Postman collection v2.1, Postman v6.0+, SAST 8.7+
