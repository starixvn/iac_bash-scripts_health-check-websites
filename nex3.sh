#!/bin/bash
file="nex3_domains.txt"
lines=`cat $file`
#lines=$(cat $file |tr "\n" " ")
for line in $lines; do
   status_code=$(curl --write-out %{http_code} --silent --output /dev/null $line)
   if [[ "$status_code" -ne 200 ]] ; then
   echo "$line - FAIL - $status_code"
   else
   #exit 0
   echo "$line - Success - $status_code"
   fi
done