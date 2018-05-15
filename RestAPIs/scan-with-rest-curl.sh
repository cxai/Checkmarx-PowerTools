#!/bin/bash

function show_help() {
    cat << EOF

 A Sample REST Application for submitting a SAST scan using pure curl commands.
 Uploads a zip file for scanning on an existing project and waits for the scan to complete.
 This script needs only curl, sed and awk for parsing.

 Run with -s/-server, -u/-user, -p/-password
  -P/-project - project name.
  -z/-zip - source code zip file

 2018 Alex Ivkin

EOF
}
function jsonValue() {
    # match on name, grep fro value, pick n'th match in the list and use xargs echo to trim leading and trailing spaces
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$1'\042/){print $(i+1)}}}' | tr -d '"' | sed -n $2p | xargs echo
}
function jsonBlock() {
    # find json block that has a matching string in it
    sed -nr "H;/$1/,/\}/{s/(\})/\1/;T;x;p};/\{/{x;s/.*\n.*//;x;H}"
}

if [[ $# -eq 0 ]]; then show_help; exit; fi

# parse params
while :; do
  case $1 in
    -h|-\?|--help)
        show_help; exit 0 ;;
    -s|-server)
        server="$2"; shift ;;
    -u|-user)
        user="$2"; shift ;;
    -p|-password)
        password="$2"; shift ;;
    -P|-project)
        project="$2"; shift ;;
    -P|-project)
        project="$2"; shift ;;
    -z|-zip)
        zip="$2"; shift ;;
    *)               # Default case: No more options, so break out of the loop.
        break
    esac
    shift
done
# check that we have everything we need
if [[ -z $user || -z $password || -z $server  || -z $project  || -z $zip ]]; then show_help; exit; fi
if [[ ! -f $zip ]]; then echo Zip $zip not found; exit 1; fi
#--------------------------------------------------------------------------------------------------
# now onto the actual work
stderr_log=$(mktemp)
# POST to login (inferred from --data)
echo "Logging in as $user..."
auth_response=$(curl --url http://$server/cxrestapi/auth/identity/connect/token \
  --header 'Cache-Control: no-cache' --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "username=$user" --data-urlencode "password=$password" \
  --data 'grant_type=password&scope=sast_rest_api&client_id=resource_owner_client&client_secret=014DF517-39D1-4453-B7B3-9930C563627C' 2>>$stderr_log)
# check for errors
err=$?; if [[ $err -gt 0 ]]; then echo "Curl failed: $err"; cat $stderr_log; rm $stderr_log; exit $err; fi
# grab the auth token
auth_token=$(echo $auth_response | jsonValue access_token)
if [[ -z $auth_token ]]; then echo "Can not authenticate: $auth_response"; exit 1; fi
#--------------------------------------------------------------------------------------------------
echo "Looking up $project..."
projects=$(curl --url http://$server/cxrestapi/projects \
  --header 'Accept: application/json;v=1.0' --header "Authorization: Bearer $auth_token" --header 'Cache-Control: no-cache' --header 'Content-Type: application/json;v=1.0' 2>>$stderr_log)
# check for curl errors
err=$?; if [[ $err -gt 0 ]]; then echo "Curl failed: $err"; cat $stderr_log; rm $stderr_log; exit $err; fi
# grab the project block
project_block=$(echo "$projects" |  jsonBlock $project)
if [[ -z "$project_block" ]]; then echo "Can not find $project project: $projects"; exit 1; fi
# get the project id from the block
project_id=$(echo "$project_block" | jsonValue id)
#--------------------------------------------------------------------------------------------------
echo "Uploading $zip ..."
upload=$(curl --url http://$server/cxrestapi/projects/$project_id/sourceCode/attachments \
  --header 'Accept: application/json;v=1.0' --header "Authorization: Bearer $auth_token" --header 'Cache-Control: no-cache' \
  --header 'Content-Type: multipart/form-data' --form "zippedSource=@$zip" 2>>$stderr_log)
# check for curl errors
err=$?; if [[ $err -gt 0 ]]; then echo "Curl failed: $err"; cat $stderr_log; rm $stderr_log; exit $err; fi
# correct code here is HTTP 204, but to check for it we'd have to get headers with -I or -w "%{http_code}". blank response is good for now.
if [[ ! -z "$upload" ]]; then echo "Can not upload $zip zip: $upload"; exit 1; fi
#--------------------------------------------------------------------------------------------------
echo "Submitting the scan ..."
scan=$(curl --url http://$server/cxrestapi/sast/scans \
  --header 'Accept: application/json;v=1.0' --header "Authorization: Bearer $auth_token" --header 'Cache-Control: no-cache' --header 'Content-Type: application/json;v=1.0' \
  --data '{ "projectId":'$project_id', "isIncremental":false, "isPublic":true, "forceScan":false }'  2>>$stderr_log)
# check for curl errors
err=$?; if [[ $err -gt 0 ]]; then echo "Curl failed: $err"; cat $stderr_log; rm $stderr_log; exit $err; fi
scan_id=$(echo $scan | jsonValue id)
if [[ -z $scan_id ]]; then echo "Can not submit the scan: $scan"; exit 1; fi
#--------------------------------------------------------------------------------------------------
echo -n "Waiting for the scan $scan_id to complete..."
status=0
while [[ $status -ne 7 && $status -ne 8 ]]; do # success or failure
    scan_status=$(curl --url http://$server/cxrestapi/sast/scans/$scan_id \
      --header 'Accept: application/json;v=1.0' --header "Authorization: Bearer $auth_token" --header 'Cache-Control: no-cache' --header 'Content-Type: application/json;v=1.0' 2>>$stderr_log)
    err=$?; if [[ $err -gt 0 ]]; then echo "Curl failed: $err"; cat $stderr_log; rm $stderr_log; exit $err; fi
    status=$(echo $scan_status | jsonValue id 3)
    echo -n ".$status"
    sleep 5
done
echo ".done."
rm $stderr_log
