#!/bin/bash
# Raw Dependency-Track API access
# Usage: dtrack-api.sh <METHOD> <endpoint> [curl-options...]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"

METHOD="${1:-GET}"; ENDPOINT="$2"; shift 2 2>/dev/null || true

if [[ -z "$ENDPOINT" ]]; then
    echo "Usage: $0 <METHOD> <endpoint> [curl-options...]" >&2
    echo "  $0 GET /v1/project" >&2
    echo "  $0 PUT /v1/analysis -d '{...}'" >&2
    exit 1
fi

curl -sfL -X "$METHOD" \
    -H "X-Api-Key: ${DTRACK_API_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    "${DTRACK_URL}/api${ENDPOINT}" "$@"
