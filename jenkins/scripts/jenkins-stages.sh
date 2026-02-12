#!/bin/bash
# Get pipeline stages and their status (requires Pipeline plugin / wfapi)
# Usage: jenkins-stages.sh <job-path> [build-number]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"
source "$SCRIPT_DIR/_api.sh"

JOB_PATH="$1"; BUILD="${2:-lastBuild}"
[[ -z "$JOB_PATH" ]] && { echo "Usage: $0 <job-path> [build-number]" >&2; exit 1; }

JOB_URL=$(echo "$JOB_PATH" | sed 's|/|/job/|g')
RESULT=$(jenkins_get "/job/${JOB_URL}/${BUILD}/wfapi/describe" 2>/dev/null || echo "")

if [[ -z "$RESULT" || "$RESULT" == "null" ]]; then
    echo "No pipeline stage data available (requires Pipeline plugin)." >&2; exit 1
fi

echo "$RESULT" | jq -r '
    "Pipeline: \(.name)",
    "Status: \(.status)",
    "Duration: \(.durationMillis / 1000 | floor)s",
    "",
    "Stages:",
    (.stages[] | "  [\(.status | if . == "SUCCESS" then "✓" elif . == "FAILED" then "✗" elif . == "IN_PROGRESS" then "⟳" else . end)] \(.name) (\(.durationMillis / 1000 | floor)s)")'
