#!/usr/bin/env bash
set -euo pipefail

export report_lock=$(mktemp)
check_status() {
  url="$1"
  status_code=$(curl --retry 5 --retry-max-time 120 --max-time 5 --connect-timeout 3 --write-out %{http_code} --silent --output /dev/null "$url")
  if [[ "$status_code" == "503" || "$status_code" == "500" || "$status_code" == "404" || "$status_code" == "000" ]]; then
    result="$url ($status_code -> FAIL)"
    echo "$result"
    # Append to report_message in a thread-safe way
    echo "{{NewLine}} ° $result" >> "$report_lock"
  else
    echo "$url ($status_code -> OK)"
  fi
}
export -f check_status

check_response() {
  url="$1"
  response=$(curl --retry 5 --retry-max-time 120 --max-time 5 --connect-timeout 3 --silent "$url")
  if [[ "$response" != "$HEALTHCHECK_KEYWORD" ]]; then
    result="$url"
    echo "$result"
    # Append to report_message in a thread-safe way
    echo "{{NewLine}} ° $result" >> "$report_lock"
  else
    echo "$url ($response -> OK)"
  fi
}
export -f check_response


main() {
  file="$1"
  if [ ! -f $file ]; then
    echo "Input file not found: $file"
    exit 1;
  else
    echo $file
  fi

  # Notify about process started
  info="🔹🔹🔹Start Healthcheck for \\\`$file\\\` 🔹🔹🔹"
  curl -d "token=$SKYNEX_TOKEN&message=$info&conversationId=$REPORT_GROUP_ID" $SKYNEX_WEBHOOK

  # Header for Message of the REPORT
  report_header="Tag Check: \\\`$CI_COMMIT_TAG\\\`{{NewLine}}"
  report_header+="Total checked: $(wc -l < $file){{NewLine}}"
  
  # Run check HEALTHPATH
  if [[ "$CI_COMMIT_TAG" =~ _healthpath(-with-hosts)?$ ]]; then
    xargs -n 1 -P $THREADS -I {} bash -c 'check_response "$@"' _ {} < "$file"

  # Run check STATUS CODE
  else
    xargs -n 1 -P $THREADS -I {} bash -c 'check_status "$@"' _ {} < "$file"
  fi

  # Gen Message when ALL CHECK PASSED
  wait
  if [ ! -s "$report_lock" ]; then
    report_message="${report_header}:bypass_active: All Healthcheck Passed!"
  else
    report_header+=":rm-rf: Failed: $(wc -l < $report_lock){{NewLine}}"
    report_message="${report_header}$(cat $report_lock)"
  fi

  # Send the FINAL REPORT
  curl -d "token=$SKYNEX_TOKEN&message=$report_message&conversationId=$REPORT_GROUP_ID" $SKYNEX_WEBHOOK
}

main "$@"