#!/bin/bash

# Configuration
ENDPOINT="http://localhost:8080/tasks"
REQUEST_COUNT=5000
CONCURRENCY=8
START_DATE="2025-04-22T10:00:00"
LOG_DIR="curl_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/stress_test_${TIMESTAMP}.log"
LOCK_FILE="${LOG_DIR}/log.lock"

# Create log directory and file
mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"

# Function to generate a unique task name
generate_task_name() {
  echo "Generate_Report_$(date +%s%N | sha256sum | head -c 8)"
}

# Function to generate a scheduledAt timestamp (increment by seconds)
generate_scheduled_at() {
  local offset=$1
  date -d "${START_DATE}+${offset} seconds" -Iseconds
}

# Function to send a single POST request and log response
send_request() {
  local index=$1
  local task_name=$(generate_task_name)
  local scheduled_at=$(generate_scheduled_at $index)
  local payload="{\"name\":\"${task_name}\",\"scheduledAt\":\"${scheduled_at}\"}"
  
  # Send curl request and capture full response (headers and body)
  local response
  response=$(curl -i -s -w "\nHTTP_STATUS:%{http_code}\n" -X POST \
    -H "Content-Type: application/json" \
    -d "${payload}" \
    "${ENDPOINT}" 2>&1)
  
  # Extract HTTP status code and first line of body for summary
  local http_status=$(echo "${response}" | grep "HTTP_STATUS" | cut -d':' -f2)
  local body_first_line=$(echo "${response}" | grep -v "HTTP_STATUS" | tail -n +$(echo "${response}" | grep -n '^$' | cut -d':' -f1 | head -1) | head -1)
  
  # Log request and response to single file with lock to prevent race conditions
  {
    flock -x 200
    echo "===== Request $index =====" >> "${LOG_FILE}"
    echo "Timestamp: $(date -Iseconds)" >> "${LOG_FILE}"
    echo "Payload: ${payload}" >> "${LOG_FILE}"
    echo "Response:" >> "${LOG_FILE}"
    echo "${response}" >> "${LOG_FILE}"
    echo "" >> "${LOG_FILE}"
  } 200>"${LOCK_FILE}"
  
  # Print summary to console
  echo "Request $index: ${task_name} at ${scheduled_at} | Status: ${http_status} | Body: ${body_first_line}"
}

# Export functions for parallel execution
export -f send_request generate_task_name generate_scheduled_at
export ENDPOINT LOG_DIR LOG_FILE LOCK_FILE START_DATE

# Generate sequence of numbers for iteration
seq 1 ${REQUEST_COUNT} | xargs -n 1 -P ${CONCURRENCY} -I {} bash -c 'send_request {}'

echo "Completed sending ${REQUEST_COUNT} requests with ${CONCURRENCY} concurrent processes."
echo "All responses logged to ${LOG_FILE}"
