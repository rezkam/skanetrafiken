#!/bin/bash
set -e
# SonarQube HTTP helper — sourced by all scripts, single place for curl flags.
#
# Usage (after sourcing _config.sh):
#   source "$SCRIPT_DIR/_api.sh"
#   sonar_get "/api/issues/search?componentKeys=myproject"
#   sonar_post "/api/issues/do_transition" -d "issue=AY123&transition=resolve"
#   sonar_raw -X POST -w "%{http_code}" "${SONARQUBE_URL}/api/..."
#
# All functions follow redirects (-L) and carry auth automatically.
# Supports both bearer token and basic auth (token:) based on SONARQUBE_AUTH_METHOD.

# GET request, returns body. Fails on HTTP error (-f).
sonar_get() {
    local endpoint="$1"; shift
    case "${SONARQUBE_AUTH_METHOD:-token}" in
        bearer) curl -sfL -H "Authorization: Bearer ${SONARQUBE_TOKEN}" "${SONARQUBE_URL}${endpoint}" "$@" ;;
        *)      curl -sfL -u "${SONARQUBE_TOKEN}:" "${SONARQUBE_URL}${endpoint}" "$@" ;;
    esac
}

# POST request, returns HTTP body + status code on last line.
# Caller splits with: body=$(sed '$d' <<< "$resp"); code=$(tail -1 <<< "$resp")
sonar_post() {
    local endpoint="$1"; shift
    case "${SONARQUBE_AUTH_METHOD:-token}" in
        bearer) curl -sL -w "\n%{http_code}" -X POST -H "Authorization: Bearer ${SONARQUBE_TOKEN}" "${SONARQUBE_URL}${endpoint}" "$@" ;;
        *)      curl -sL -w "\n%{http_code}" -X POST -u "${SONARQUBE_TOKEN}:" "${SONARQUBE_URL}${endpoint}" "$@" ;;
    esac
}

# Raw curl with auth pre-filled. Caller controls all other flags.
sonar_raw() {
    case "${SONARQUBE_AUTH_METHOD:-token}" in
        bearer) curl -L -H "Authorization: Bearer ${SONARQUBE_TOKEN}" "$@" ;;
        *)      curl -L -u "${SONARQUBE_TOKEN}:" "$@" ;;
    esac
}
