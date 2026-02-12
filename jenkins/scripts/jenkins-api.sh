#!/bin/bash
# Raw Jenkins API access
# Usage: jenkins-api.sh <endpoint> [curl-options...]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"
source "$SCRIPT_DIR/_api.sh"

ENDPOINT="$1"; shift 2>/dev/null || true
[[ -z "$ENDPOINT" ]] && { echo "Usage: $0 <endpoint> [curl-options...]" >&2; exit 1; }

jenkins_get "$ENDPOINT" "$@"
