# Scripts to automate and simplify Checkmarx installations and maintenance

## Remove Cx load delay after IIS is restarted - `cx-init-webapps-on-iis-restart.ps1`
Cx may take up to several minutes to load the first time it is accessed after an IIS restart or a box reboot. You can mitigate it by configuring IIS built-in feature called "application initialization".
Using it IIS will warming-up CxSAST, so you do not have to wait for CxSAST to load when accessing it for the first time.

## Set default link to CxWebClient - `redirect-webroot-to-cxwebclient.ps1`
Accessing CxSAST out of the box installation on the root url `/` shows the default.aspx IIS page. If you want your webserver to be automatically redirected to the CxSAST interface, run this script
Note that it will pull in and install an optional IIS module called "url rewrite".

## Checkmarx Zip tool for Linux and Mac - `cxzip.sh`
A bash script to zip up only the files that Checkmarx can scan. This script can be reduced to this one-liner:

`zip -r zipname.zip foldername -i@<( sed 's/^/*/' CxExt.txt )`

CxExt.txt is the file from the Checkmarx [CxZip distribution](https://download.checkmarx.com/CXPS/CxServices/Cx7Zip.zip). `-i@` is for zip to use a file for file patterns, `<(...)` is a special bash construct to pipe output through a file handle, `sed` is to prefix everything with a * wildcard
