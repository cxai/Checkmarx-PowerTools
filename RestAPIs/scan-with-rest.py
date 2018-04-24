#!/usr/bin/python3
"""
A Sample REST Application showcasing project creation, SAST and OSA scans.
Uses CxREST python implementation class. Need CxREST.py and __init__.py in the same folder.

Does the following:
1. Creates a project if one is not present
2. Submits three scans for different branches in a github repo
3. Submits an OSA scan

Uses OAuth bearer token authentication.

Tested against 8.7 APIs
"""
__author__ = 'Alex Ivkin'
__version__ = "1.0"

import os, sys, traceback, argparse, logging, requests
from CxREST import CxREST

PROJECT="JavaApp"
TEAM="\\CxServer" #ideally we should get this from the user record, but as of 8.7 no such api exists
PRESET="Checkmarx Default"
ENGINECONFIG="Default Configuration"

print("REST API client v%s" % __version__)
parser = argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('-s','--server', help='Server host name or IP', required=True)
parser.add_argument('-u','--user', help='API user', required=True)
parser.add_argument('-p','--password', help='API password', required=True)
args = parser.parse_args()
try:
    api=CxREST.API()
    api.login(args.server,args.user,args.password)
    projects=api.projects()
    if PROJECT in projects:
        print(PROJECT+" project found")
        projectId=projects[PROJECT]
    else:
        print("Creating %s project" % PROJECT)
        teams=api.teams()
        if TEAM not in teams:
            raise Exception("Team %s not found"%TEAM)
        projectId=api.createProject(PROJECT,teams[TEAM])
    presets=api.presets()
    if PRESET not in presets:
        raise Exception("Preset %s not found"%PRESET)
    engconfigs=api.engineConfigs()
    if ENGINECONFIG not in engconfigs:
        raise Exception("Engine configuration %s not found"%ENGINECONFIG)
    print("Configuring %s project" % PROJECT)
    api.setScanSettings(projectId,presets[PRESET],engconfigs[ENGINECONFIG])
    api.setSourceToGit(projectId,"https://github.com/cxai/NetStore","refs/tags/v1")
    api.waitToComplete(api.startSASTScan(projectId))
    api.setSourceToGit(projectId,"https://github.com/cxai/NetStore","refs/tags/v2")
    api.waitToComplete(api.startSASTScan(projectId))
    api.setSourceToGit(projectId,"https://github.com/cxai/NetStore","refs/tags/v3")
    api.waitToComplete(api.startSASTScan(projectId))
    # get and save the OSA file first
    r = requests.get("https://github.com/cxai/NetStore/raw/master/javalibs.zip", stream=True)
    with open("javalibs.zip", 'wb') as f:
        for c in r.iter_content(chunk_size=1024):
            if c:
                f.write(c)
    scanid=api.startOSAScan(projectId,"javalibs.zip")
    os.unlink("javalibs.zip")
    api.waitToComplete(scanid,isOSA=True)
except:
    print("%s@%s - Exception %s: %s" % (args.server, args.user, sys.exc_info()[0],sys.exc_info()[1]))
    traceback.print_exc()
    sys.exit(1)
