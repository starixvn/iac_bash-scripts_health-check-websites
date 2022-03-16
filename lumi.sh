#!/bin/bash
file="lumi_domains.txt"
lines=`cat $file`
#lines=$(cat $file |tr "\n" " ")
for line in $lines; do
   status_code=$(curl --write-out %{http_code} --silent --output /dev/null $line)
   #if echo $status_code | grep -q "503";
   if [ "$status_code" == "503" ] || [ "$status_code" == "500" ] || [ "$status_code" == "000" ]
   then echo "$line - FAIL - $status_code - warning";
   else echo "$line - Success - $status_code";
   fi;
done