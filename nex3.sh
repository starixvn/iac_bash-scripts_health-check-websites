#!/bin/bash
file="nex3_domains.txt"
lines=`cat $file`
#lines=$(cat $file |tr "\n" " ")
for line in $lines; do
   status_code=$(curl --write-out %{http_code} --silent --output /dev/null $line)
   if echo $status_code | grep -q "503"; 
   then echo "$line - FAIL - $status_code - warning";
   elif echo $DEPLOY_ENV | grep -q "302"; 
   then echo "$line - $status_code";
   elif echo $DEPLOY_ENV | grep -q "200"; 
   then echo "$line - Success - $status_code";
   else
   #exit 0
   echo "$line - $status_code ---";
   fi
done