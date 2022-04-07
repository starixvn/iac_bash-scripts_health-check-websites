#!/bin/bash
file="domains/$1.txt";
echo $file;
if [ ! -f $file ]; then
    echo "File $file not found!"
    exit 1;
fi;
lines=`cat $file`
#lines=$(cat $file |tr "\n" " ")
for line in $lines; do
   status_code=$(curl --max-time 5 --connect-timeout 3 --write-out %{http_code} --silent --output /dev/null $line)
   #if echo $status_code | grep -q "503";
   if [ "$status_code" == "503" ] || [ "$status_code" == "500" ] || [ "$status_code" == "404" ] || [ "$status_code" == "000" ]
   then result="$line ($status_code -> FAIL)";echo "$result";
   curl -d "token=0A40aOc7CtpzjbBSJu8KNWQRoXyjRvf9&message=$result&conversationId=19:fca7f2d1cc2949de8888faa2f3096861@thread.skype" https://bot.nexdev.net/skynex/api/messages/ForwardWithToken;
   curl -d "token=0A40aOc7CtpzjbBSJu8KNWQRoXyjRvf9&message=$result&conversationId=-1001172443943" https://bot.nexdev.net/skynex/api/messages/ForwardWithToken;
   else result="$line $status_code -> OK)";echo "$result";
   fi;
done