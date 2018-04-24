# Scripts to automate setup and maintenance of Checkmarx installations

## Remove Cx load delay after IIS is restarted - `cx-init-webapps-on-iis-restart.ps1`
Cx may take up to several minutes to load the first time it is accessed after an IIS restart or a box reboot. You can mitigate it by configuring IIS built-in feature called "application initialization".
Using it IIS will warming-up CxSAST, so you do not have to wait for CxSAST to load when accessing it for the first time.

## Set default link to CxWebClient - `redirect-webroot-to-cxwebclient.ps1`
Accessing CxSAST out of the box installation on the root url `/` shows the default.aspx IIS page. If you want your webserver to be automatically redirected to the CxSAST interface, run this script
Note that it will pull in and install an optional IIS module called "url rewrite".
