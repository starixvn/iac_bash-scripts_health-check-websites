#!/usr/bin/env bash
set -euo pipefail

export report_lock=$(mktemp)
check_url() {
  url="$1"
  status_code=$(curl --retry 5 --retry-max-time 120 --max-time 5 --connect-timeout 3 --write-out %{http_code} --silent --output /dev/null "$url")
  if [[ "$status_code" == "503" || "$status_code" == "500" || "$status_code" == "404" || "$status_code" == "000" ]]; then
    result="$url ($status_code -> FAIL)"
    echo "$result"
    # Append to report_message in a thread-safe way
    echo "{{NewLine}}{{Error}} $result" >> "$report_lock"
  else
    echo "$url ($status_code -> OK)"
  fi
}
export -f check_url


main() {
  file="domains/$1.txt"
  if [ ! -f $file ]; then
    echo "Input file not found: $file"
    exit 1;
  else
    echo $file
  fi

  # Notify about process started
  info="🔹🔹🔹Start Checking for $file 🔹🔹🔹"
  curl -d "token=$SKYNEX_TOKEN&message=$info&conversationId=$REPORT_GROUP_ID" $SKYNEX_WEBHOOK

  # Run checks in parallel
  xargs -n 1 -P $THREADS -I {} bash -c 'check_url "$@"' _ {} < "$file"

  # Collect the report after all background jobs finish
  wait
  report_message=$(cat "$report_lock")
  rm "$report_lock"

  if [ -z $report_message ]; then
    report_message="{{Success}} All domains on $file is healthy {{Success}}"
  fi

  # Send the final report
  curl -d "token=$SKYNEX_TOKEN&message=$report_message&conversationId=$REPORT_GROUP_ID" $SKYNEX_WEBHOOK
}

main "$@"