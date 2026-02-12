#!/bin/bash
set -e
# Jenkins HTTP helper — sourced by all scripts, single place for curl flags.
#
# Usage (after sourcing _config.sh):
#   source "$SCRIPT_DIR/_api.sh"
#   jenkins_get  "/job/MyOrg/job/main/lastBuild/api/json?tree=result"
#   jenkins_post "/job/MyOrg/job/main/build"
#   jenkins_raw  -X POST -o /dev/null -w "%{http_code}" "${JENKINS_URL}/job/..."
#
# All functions follow redirects (-L) and carry auth automatically.

# GET request, returns JSON body. Fails on HTTP error (-f).
jenkins_get() {
    curl -sfL -u "${JENKINS_USER}:${JENKINS_TOKEN}" "${JENKINS_URL}$1" "${@:2}"
}

# POST request, returns HTTP status code. Body is discarded.
# Does NOT use -f: callers check the returned status code themselves.
jenkins_post() {
    curl -sL -o /dev/null -w "%{http_code}" -X POST \
        -u "${JENKINS_USER}:${JENKINS_TOKEN}" "${JENKINS_URL}$1" "${@:2}"
}

# Raw curl with auth pre-filled. Caller controls all other flags.
jenkins_raw() {
    curl -L -u "${JENKINS_USER}:${JENKINS_TOKEN}" "$@"
}
