#!/usr/bin/python3
"""
A Sample REST Application showcasing the Rest API.
Tested against 8.8 APIs
"""
from __future__ import print_function

__author__ = 'Alex Ivkin'
__version__ = "1.0"

import os, sys, traceback, argparse, logging, requests, json
from CxREST import CxREST

PROJECT="NetStore"

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
    if PROJECT not in projects:
       raise Exception("Project %s not found" % PROJECT)
    projectId=projects[PROJECT]
    scans=json.loads(api.scans(projectId).content)
    print(json.dumps(scans, indent=4))
except:
    print("%s@%s - Exception %s: %s" % (args.server, args.user, sys.exc_info()[0],sys.exc_info()[1]))
    traceback.print_exc()
    sys.exit(1)
