# check if needs to be registered with a manager
if (($null -eq $env:sast_server) -or ($null -eq $env:sast_admin) -or ($null -eq $env:sast_adminpwd) -or ($env:sast_server -eq '_') -or ($env:sast_admin -eq '_') -or ($env:sast_adminpwd -eq '_')) {
    Write-Host "CxSAST server name, admin user name or password is not specified. Will not registers this engine."  -ForegroundColor yellow
} else {
# Add to the list of available engines
    Write-Host "Reviewing CxSAST Engine registration with $env:sast_server..."

    #$person = @{username='admin@cx';password='admin'}
    #$admin=(convertto-json $person)  
    $admin="{username:'$env:sast_admin',password:'$env:sast_adminpwd'}"
    try {
       $JSONResponse=Invoke-RestMethod -uri http://$env:sast_server/cxrestapi/auth/login -method post -body $admin -contenttype 'application/json' -sessionvariable sess
    } catch { 
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        throw "Could not authenticate" 
    }
    # grab the token
    $headers=@{"CXCSRFToken"=$sess.Cookies.GetCookies("http://$env:sast_server/cxrestapi/auth/login")["CXCSRFToken"].Value}
    # get the list of all configured engines
    try { 
       $JSONResponse=invoke-restmethod -uri http://$env:sast_server/cxrestapi/sast/engineservers -method get -contenttype 'application/json' -headers $headers -WebSession $sess
    } catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        throw "Error listing servers" 
    } 
    # iterate over the names of the servers
    $addnew=$true
    foreach($engine in $JSONResponse) {
       if ($engine.name -eq 'Localhost'){
    	Write-Host "Localhost engine is registered. You might want to remove it." -ForegroundColor yellow
       }
       if ($engine.name -eq $(hostname)){
    	Write-Host "$(hostname) is already registered"
    	$addnew=$false
    	break	
       }
    }
    # see if we need to add ourselves
    if ($addnew) {
       Write-Host "Registering the CxSAST Engine $(hostname)..."
       $engine='{"name":"'+$(hostname)+'","uri":"http://'+$(hostname)+'/CxSourceAnalyzerEngineWCF/CxEngineWebServices.svc","minLoc":0,"maxLoc":99999999,"isBlocked":false}'
       try { 
       	$JSONResponse=Invoke-RestMethod -uri http://$env:sast_server/cxrestapi/sast/engineservers -method post -body $engine -contenttype 'application/json' -headers $headers -WebSession $sess
       } catch {
       	Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
       	Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
       	throw "Could not register"
       }
    } 
}
