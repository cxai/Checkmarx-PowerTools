#!/bin/bash

#  Create a zip of scannable files for Checkmarx

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # script folder

command -v zip >/dev/null 2>&1 || { echo >&2 "'zip' is not found. Aborting."; exit 1; }
command -v sed >/dev/null 2>&1 || { echo >&2 "'sed' is not found. Aborting."; exit 1; }

if [ $# -lt 2 ]; then
    echo "Usage: $DIR/$0 <zip name> <directory>"
    exit 1
fi

if [ ! -f "$DIR/CxExt.txt" ]; then
    echo "Cannot find $DIR/CxExt.txt file. Please extract it from https://download.checkmarx.com/CXPS/CxServices/Cx7Zip.zip or https://download.checkmarx.com/CXPS/CxServices/CxZip.zip"
    exit 1
fi

# CxExt.txt is the file from CxZip distribution.
# -i@ is for zip to use a file for file patterns, <(...) is a special bash construct to pipe output through a file handle, sed is to prefix everything with a * wildcard

zip -r $1 $2 -i@<( sed 's/^/*/' "$DIR/CxExt.txt" )
