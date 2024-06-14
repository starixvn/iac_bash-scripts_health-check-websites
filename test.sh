#!/bin/bash
file="domains/$1.txt";
echo $file;
if [ ! -f $file ]; then
    echo "File $file not found!"
    exit 1;
fi;
lines=`cat $file`
#lines=$(cat $file |tr "\n" " ")
info="========Start Checking for $file ======="
curl -d "token=0A40aOc7CtpzjbBSJu8KNWQRoXyjRvf9&message=$info&conversationId=19:7bbc32eca7a74681adb19e97d9ead538@thread.tacv2" https://bot.nexdev.net/skynex/api/messages/ForwardWithToken;


report_message=""
for line in $lines; do
   status_code=$(curl --retry 5  --retry-max-time 120 --max-time 5 --connect-timeout 3 --write-out %{http_code} --silent --output /dev/null $line)
   #if echo $status_code | grep -q "503";
   if [ "$status_code" == "503" ] || [ "$status_code" == "500" ] || [ "$status_code" == "404" ] || [ "$status_code" == "000" ]; then
      result="$line ($status_code -> FAIL)";
      echo "$result";
      report_message=$report_message"{{NewLine}}{{Error}} $result"
   else 
      result="$line $status_code -> OK)";echo "$result";
   fi;
done

if [ ! $report_message ]; then
   report_message="{{Success}} All domains is healthy {{Success}}"


curl -d "token=0A40aOc7CtpzjbBSJu8KNWQRoXyjRvf9&message=$report_message&conversationId=19:7bbc32eca7a74681adb19e97d9ead538@thread.tacv2" https://bot.nexdev.net/skynex/api/messages/ForwardWithToken;

info="========End Checking for $file ========"
curl -d "token=0A40aOc7CtpzjbBSJu8KNWQRoXyjRvf9&message=$info&conversationId=19:7bbc32eca7a74681adb19e97d9ead538@thread.tacv2" https://bot.nexdev.net/skynex/api/messages/ForwardWithToken;
