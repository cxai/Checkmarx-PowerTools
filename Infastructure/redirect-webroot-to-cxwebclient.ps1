# https://docs.microsoft.com/en-us/iis/extensions/url-rewrite-module/url-rewrite-module-configuration-reference

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	Write-Host "Run this as a local admin" -foregroundcolor red
	exit 1
}

$RewriteDllPath = Join-Path $Env:SystemRoot 'System32\inetsrv\rewrite.dll'
if (! (Test-Path -Path $RewriteDllPath)){
	Write-Host "Installing URL rewrite..."
	Invoke-WebRequest http://download.microsoft.com/download/D/D/E/DDE57C26-C62C-4C59-A1BB-31D58B36ADA2/rewrite_amd64_en-US.msi -OutFile rewrite_amd64.msi -UseBasicParsing
    	Start-Process msiexec.exe -ArgumentList '/i', 'rewrite_amd64.msi', '/quiet', '/norestart' -NoNewWindow -Wait
    	Remove-Item rewrite_amd64.msi
	Restart-Service W3SVC   
}

if (!(Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule" -name ".") -or
    !(Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule" -name ".").name.contains("RedirectRootToCxWebClient") ) {
	Write-Host "Configuring default forwarder..."
	Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules" -name "." -value @{name='RedirectRootToCxWebClient';stopProcessing='True'}
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule[@name='RedirectRootToCxWebClient']/match" -name "url" -value "^$"
	#Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule[@name='RedirectRootToCheckmarx']/conditions" -name "." -value @{input='{CACHE_URL}';pattern='^(https?)://'}
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule[@name='RedirectRootToCxWebClient']/action" -name "url" -value "/CxWebClient/"
	# type could also be "RedirectToSubdir"
	Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/rewrite/rules/rule[@name='RedirectRootToCxWebClient']/action" -name "type" -value "Redirect"

}
