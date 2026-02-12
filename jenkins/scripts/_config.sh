#!/bin/bash
# Jenkins configuration loader
set -e

_JENKINS_CONFIG_DIR="${JENKINS_CONFIG_DIR:-$HOME/.boring/jenkins}"

# Read URL from file
if [ -z "$JENKINS_URL" ] && [ -f "${_JENKINS_CONFIG_DIR}/url" ]; then
    JENKINS_URL=$(tr -d '[:space:]' < "${_JENKINS_CONFIG_DIR}/url")
fi

# Read user from file
if [ -z "$JENKINS_USER" ] && [ -f "${_JENKINS_CONFIG_DIR}/user" ]; then
    JENKINS_USER=$(tr -d '[:space:]' < "${_JENKINS_CONFIG_DIR}/user")
fi

# Read token from file
if [ -z "$JENKINS_TOKEN" ] && [ -f "${_JENKINS_CONFIG_DIR}/token" ]; then
    JENKINS_TOKEN=$(tr -d '[:space:]' < "${_JENKINS_CONFIG_DIR}/token")
fi

JENKINS_URL="${JENKINS_URL:-}"
JENKINS_USER="${JENKINS_USER:-}"
JENKINS_TOKEN="${JENKINS_TOKEN:-}"

if [ -z "$JENKINS_URL" ]; then
    echo "Error: JENKINS_URL not set. Create ${_JENKINS_CONFIG_DIR}/url or run setup.sh." >&2
    exit 1
fi
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
    echo "Error: JENKINS_USER and JENKINS_TOKEN required. Create files in ${_JENKINS_CONFIG_DIR}/ or run setup.sh." >&2
    exit 1
fi
