#!/bin/bash
# SonarQube configuration loader
set -e

_SONAR_CONFIG_DIR="${SONAR_CONFIG_DIR:-$HOME/.boring/sonarqube}"

# Read URL from file
if [ -z "$SONARQUBE_URL" ] && [ -f "${_SONAR_CONFIG_DIR}/url" ]; then
    SONARQUBE_URL=$(tr -d '[:space:]' < "${_SONAR_CONFIG_DIR}/url")
fi

SONARQUBE_URL="${SONARQUBE_URL:-}"
SONARQUBE_TOKEN_FILE="${SONARQUBE_TOKEN_FILE:-${_SONAR_CONFIG_DIR}/token}"

if [ -z "$SONARQUBE_URL" ]; then
    echo "Error: SONARQUBE_URL not set. Create ${_SONAR_CONFIG_DIR}/url or run setup.sh." >&2
    exit 1
fi

if [ ! -f "$SONARQUBE_TOKEN_FILE" ]; then
    echo "Error: Token not found at $SONARQUBE_TOKEN_FILE" >&2
    echo "  mkdir -p ${_SONAR_CONFIG_DIR}" >&2
    echo "  echo 'your-token' > ${SONARQUBE_TOKEN_FILE}" >&2
    echo "  chmod 600 ${SONARQUBE_TOKEN_FILE}" >&2
    exit 1
fi

SONARQUBE_TOKEN=$(tr -d '[:space:]' < "$SONARQUBE_TOKEN_FILE")
if [ -z "$SONARQUBE_TOKEN" ]; then
    echo "Error: Token file is empty at $SONARQUBE_TOKEN_FILE" >&2
    exit 1
fi

# Read auth method from file (default: token-as-login)
if [ -z "${SONARQUBE_AUTH_METHOD:-}" ] && [ -f "${_SONAR_CONFIG_DIR}/auth_method" ]; then
    SONARQUBE_AUTH_METHOD=$(tr -d '[:space:]' < "${_SONAR_CONFIG_DIR}/auth_method")
fi
SONARQUBE_AUTH_METHOD="${SONARQUBE_AUTH_METHOD:-token}"
