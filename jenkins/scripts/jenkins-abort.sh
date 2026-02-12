#!/bin/bash
# Abort a running build
# Usage: jenkins-abort.sh <job-path> [build-number]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"
source "$SCRIPT_DIR/_api.sh"

JOB_PATH="$1"; BUILD="${2:-lastBuild}"
[[ -z "$JOB_PATH" ]] && { echo "Usage: $0 <job-path> [build-number]" >&2; exit 1; }

JOB_URL=$(echo "$JOB_PATH" | sed 's|/|/job/|g')
HTTP_CODE=$(jenkins_post "/job/${JOB_URL}/${BUILD}/stop")

if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" ]]; then
    echo "Build ${BUILD} aborted for ${JOB_PATH}"
else
    echo "Failed to abort. HTTP ${HTTP_CODE}" >&2; exit 1
fi
