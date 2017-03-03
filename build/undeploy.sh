#!/usr/bin/env bash

#deploy destructiveChanges.xml
result=$((ant undeployCode -Dsf.target.username=$sfusername -Dsf.target.password=$sfpassword -Dsf.target.serverurl=$sfserverurl -Dsf.testLevel=$sftestlevel) 2>&1)
 
echo "result: $result"
#parse the build output, allow Warnings but fail on FAILED
if [[ $result == *Warning* ]]; then
    echo '**** Got a warning, probably okay - Passing ****'
    exit 0;
elif [[ $result == *FAILED* ]]; then
    echo '**** Got an error - Failing ****'
    exit 3;
fi
exit 0;
