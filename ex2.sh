#!/bin/bash
# sudo apt install nginx curl pup
# curl http://127.0.0.1

set -euo pipefail

total_request="${1:-3}"
# response_dir="/tmp/linux_b2"
# mkdir -p "$response_dir"
response_dir=$(mktemp -d)
access_log="/var/log/nginx/access.log"

display_result() {
    # local http_code="$1" 
    if [[ "$http_code" -ge 400 ]]; then
        cat "$response_dir/response.html" | pup 'title text{}' >&2
    else 
        cat "$response_dir/response.html" | pup 'title text{}'
    fi
}

send_request() {
    local url="http://localhost/${1}"
    echo " -- Requesting $url"
    http_code="$(curl -s --output "$response_dir/response.html" --write-out '%{http_code}' "$url")"
    display_result "$http_code"
}

run_test() {
    echo "Sending $total_request error and access request"
    for ((request_number = 1; request_number <= total_request; request_number++)); do
        send_request ""
        send_request "error"
    done
    echo "inside $request_number"
}

compare_logs() {
    new_access_lines=$((access_lines_after - access_lines_before))
    expected_access_lines=$((total_request * 2))
    echo "Number of access log lines: before=$access_lines_before after=$access_lines_after new=$new_access_lines expected_changes=$expected_access_lines"
    if [[ "$new_access_lines" -ne $expected_access_lines ]]; then
        echo "Error: log line number do not match" >&2
        return 1
    fi
    echo "Number of Log lines match"
}



nginx_test_log_consistency() {
    access_lines_before="$(wc -l <"$access_log")"
    run_test
    echo "outside $request_number"
    access_lines_after="$(wc -l <"$access_log")"
    compare_logs
}


nginx_test_log_consistency