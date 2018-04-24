'''
Python abstraction for Checkmarx REST API's

Tested on 8.7 API
'''
__author__ = 'Alex Ivkin'
__version__ = "1.0"

import time, json, requests

class API:
    #def __init__(self):
    #    print("heer")
    #     self.server=Server
    def login(self,server,user,password):
        self.server="http://%s" % server
        self.user=user
        login_url = "/cxrestapi/auth/identity/connect/token"
        login_payload = "username=%s&password=%s&grant_type=password&scope=sast_rest_api&client_id=resource_owner_client&client_secret=014DF517-39D1-4453-B7B3-9930C563627C" % (user,password)
        login_headers = { 'Content-Type': "application/x-www-form-urlencoded", 'Cache-Control': "no-cache" }  # headers are optional
        response = requests.post(self.server+login_url, data=login_payload, headers=login_headers)
        if response.status_code != 200:
            raise Exception("Can not login to %s as %s: %s"%(server,user,response.text))
        self.token = json.loads(response.text)['access_token']
        self.rest_headers = {'Authorization': 'Bearer ' + self.token, 'Content-Type': 'application/json;v=1.0', 'cxOrigin':'RestAPI'}

    def projects(self):
        url = '/CxRestAPI/projects'
        results = json.loads(requests.get(self.server+url, data='', headers=self.rest_headers).text)
        #response = requests.get(self.server+url, data='', headers=self.rest_headers)
        #if response.status_code != 200:
        #    raise Exception("Error listing projects: %s"%response.text)
        #results = json.loads(response.text)
        # self.print(json.dumps(projects, indent=4, sort_keys=True))
        # a more consumable name:id dict,with a side effect of conflating identically named projects
        return dict(zip([p["name"] for p in results],[p["id"] for p in results]))

    def teams(self):
        url = '/CxRestAPI/auth/teams'
        results = json.loads(requests.get(self.server+url, data='', headers=self.rest_headers).text)
        #response = requests.get(self.server+url, data='', headers=self.rest_headers)
        #if response.status_code != 200:
        #    raise Exception("Error listing teams: %s"%response.text)
        #print(json.dumps(response.text, indent=4, sort_keys=True))
        #results = json.loads(response.text)
        # a more consumable name:id dict,with a side effect of conflating identically named projects
        return dict(zip([p["fullName"] for p in results],[p["id"] for p in results]))

    def presets(self):
        url = '/CxRestAPI/sast/presets'
        results = json.loads(requests.get(self.server+url, data='', headers=self.rest_headers).text)
        return dict(zip([p["name"] for p in results],[p["id"] for p in results]))

    def engineConfigs(self):
        url = '/CxRestAPI/sast/engineConfigurations'
        results = json.loads(requests.get(self.server+url, data='', headers=self.rest_headers).text)
        return dict(zip([p["name"] for p in results],[p["id"] for p in results]))

    def createProject(self,name,teamid):
        url = '/CxRestAPI/projects'
        payload={"name" : name,"owningTeam":teamid,"isPublic":"true"}
        response = requests.post(self.server+url, data=json.dumps(payload), headers=self.rest_headers)
        if response.status_code != 201:
            raise Exception("Cant create project "+name)
        return json.loads(response.text)["id"]

    def startSASTScan(self,projectid,incremental=False,public=True,force=False):
        url = '/CxRestAPI/sast/scans'
        payload={"projectId":projectid,"isIncremental":incremental,"isPublic":public,"forceScan":force}
        response = requests.post(self.server+url, data=json.dumps(payload), headers=self.rest_headers)
        if response.status_code != 201:
            raise Exception("SAST Scan failed "+str(response))
        return json.loads(response.text)["id"]

    def startOSAScan(self,projectid,file):
        url = '/CxRestAPI/osa/scans'
        payload={"projectId":projectid}
        file={"zippedSource": open(file,'rb')}
        # drop content type, dont json encode data
        response = requests.post(self.server+url, data=payload, headers={'Authorization':self.rest_headers['Authorization']}, files=file)
        if response.status_code != 202:
            raise Exception("OSA Scan failed "+str(response))
        return json.loads(response.text)["scanId"]

    def setSourceToGit(self,projectid,giturl,branch):
        url='/CxRestAPI/projects/%d/sourceCode/remoteSettings/git' % projectid
        payload={"url":giturl,"branch":branch}
        response = requests.post(self.server+url, data=json.dumps(payload), headers=self.rest_headers)
        if response.status_code != 204:
            raise Exception("Can't set project source to "+giturl)

    def setScanSettings(self,projectid,presetid,engineconfigid):
        url='/CxRestAPI/sast/scanSettings'
        payload={"projectId":projectid,"presetId":presetid,"engineConfigurationId":engineconfigid}
        # optional:
        # postScanActionId=[integer] - Unique Id of the post scan action
        # emailNotifications=[body] - Email notification details:
        # beforescan=[string] - Specifies the email to send the pre-scan message
        # failedScans=[string] - Specifies the email to send the scan failure message
        # afterScans=[string] - Specifies the email to send the post-scan message
        response = requests.post(self.server+url, data=json.dumps(payload), headers=self.rest_headers)
        if response.status_code != 200:
            raise Exception("Can't set scan settings to "+str(payload))
        return json.loads(response.text)["id"]

    def waitToComplete(self,scanid,isOSA=False):
        url='/CxRestAPI/%s/scans/%s' % ("osa" if isOSA else "sast",str(scanid))
        timespent=0
        sleepsec=1
        while True:
            response=requests.get(self.server+url, data='', headers=self.rest_headers)
            if response.status_code != 200:
                raise Exception("Error checking "+str(scanid))
            status = json.loads(response.text)["state" if isOSA else "status"]
            print("Waiting for the %s scan %s to complete: %s(%d) - %d sec.                     \r" % ("OST" if isOSA else "SAST",str(scanid),status["name"],status["id"],timespent),end='',flush=False)
            if (status["id"] == 7 and not isOSA) or (status["id"] == 2 and isOSA):
                print()
                break
            time.sleep(sleepsec)
            timespent+=sleepsec
