#https://docs.microsoft.com/en-us/iis/configuration/system.webserver/applicationinitialization/
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	Write-Host "Run this as a local admin" -foregroundcolor red
	exit 1
}

if ((Get-WindowsOptionalFeature -FeatureName IIS-ApplicationInit -Online).State -ne "Enabled") {
	Write-Host "Installing the IIS application initialization module"
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit | out-null
}

if (!(Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name ".").collection -or 
    !(Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name ".").collection.initializationPage -eq '/CxWebClient/ProjectState.aspx' ){
	Write-Host "Enabling Checkmarx application initialization"  
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/applicationPools/add[@name='CxPool']" -name "startMode" -value "AlwaysRunning"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/applicationPools/add[@name='CxPoolRestAPI']" -name "startMode" -value "AlwaysRunning"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/applicationPools/add[@name='CxClientPool']" -name "startMode" -value "AlwaysRunning"

	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='Default Web Site']/application[@path='/CxWebClient']" -name "preloadEnabled" -value "True"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='Default Web Site']/application[@path='/CxWebInterface']" -name "preloadEnabled" -value "True"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='Default Web Site']/application[@path='/CxRestAPI']" -name "preloadEnabled" -value "True"

	#echo "Checkmarx is loading, please wait..." | out-file -encoding ascii "C:\inetpub\wwwroot\checkmarxloading.htm"
	#Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name "remapManagedRequestsTo" -value "/checkmarxloading.htm"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name "skipManagedModules" -value "False"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name "doAppInitAfterRestart" -value "True"
	Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/applicationInitialization" -name "." -value @{initializationPage='/CxWebClient/ProjectState.aspx'}
	Restart-Service W3SVC
}
