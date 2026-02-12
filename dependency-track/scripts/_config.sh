#!/bin/bash
# Dependency-Track configuration loader
set -e

_DTRACK_CONFIG_DIR="${DTRACK_CONFIG_DIR:-$HOME/.boring/dependency-track}"

# Read URL from file
if [ -z "$DTRACK_URL" ] && [ -f "${_DTRACK_CONFIG_DIR}/url" ]; then
    DTRACK_URL=$(tr -d '[:space:]' < "${_DTRACK_CONFIG_DIR}/url")
fi

DTRACK_URL="${DTRACK_URL:-}"
DTRACK_API_KEY_FILE="${DTRACK_API_KEY_FILE:-${_DTRACK_CONFIG_DIR}/apikey}"

if [ -z "$DTRACK_URL" ]; then
    echo "Error: DTRACK_URL not set. Create ${_DTRACK_CONFIG_DIR}/url or run setup.sh." >&2
    exit 1
fi

if [ ! -f "$DTRACK_API_KEY_FILE" ]; then
    echo "Error: API key not found at $DTRACK_API_KEY_FILE" >&2
    echo "  mkdir -p ${_DTRACK_CONFIG_DIR}" >&2
    echo "  echo 'your-api-key' > ${DTRACK_API_KEY_FILE}" >&2
    echo "  chmod 600 ${DTRACK_API_KEY_FILE}" >&2
    exit 1
fi

DTRACK_API_KEY=$(tr -d '[:space:]' < "$DTRACK_API_KEY_FILE")
if [ -z "$DTRACK_API_KEY" ]; then
    echo "Error: API key file is empty at $DTRACK_API_KEY_FILE" >&2
    exit 1
fi
