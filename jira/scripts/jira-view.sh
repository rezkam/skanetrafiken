#!/bin/bash
# View a Jira issue
# Usage: jira-view.sh <issue-key> [--comments]
#
# Examples:
#   jira-view.sh PROJ-123
#   jira-view.sh PROJ-123 --comments

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/_config.sh"

ISSUE="${1:-}"
if [ -z "$ISSUE" ]; then
    cat >&2 << 'EOF'
ERROR: Missing issue key.

Usage:
  jira-view.sh <issue-key>              View issue details
  jira-view.sh <issue-key> --comments   Include comments

The issue key is the project prefix + number (e.g. PROJ-123, PROJ-456).

Examples:
  jira-view.sh PROJ-123
  jira-view.sh PROJ-123 --comments
EOF
    exit 1
fi
shift

SHOW_COMMENTS=false
for arg in "$@"; do
    case "$arg" in
        --comments) SHOW_COMMENTS=true ;;
    esac
done

# Get issue details via API for structured output
RESPONSE=$("$SCRIPT_DIR/jira-api.sh" GET "/rest/api/3/issue/${ISSUE}?fields=summary,status,issuetype,assignee,reporter,priority,labels,created,updated,description" 2>&1)
RC=$?

if [ $RC -ne 0 ]; then
    cat >&2 << EOF
ERROR: Failed to fetch issue ${ISSUE}.

${RESPONSE}

Common causes:
  - Issue does not exist: double-check the key (e.g. PROJ-123, not PROJ123).
  - Permission denied: you may not have access to this project.
  - Auth expired: test with $SCRIPT_DIR/jira-api.sh GET /rest/api/3/myself

To search for issues instead:
  $SCRIPT_DIR/jira-search.sh "keyword"
  $SCRIPT_DIR/jira-list.sh --assignee me
EOF
    exit $RC
fi

echo "$RESPONSE" | jq '{
    key: .key,
    summary: .fields.summary,
    status: .fields.status.name,
    type: .fields.issuetype.name,
    priority: .fields.priority.name,
    assignee: (.fields.assignee.displayName // "Unassigned"),
    reporter: .fields.reporter.displayName,
    labels: .fields.labels,
    created: .fields.created,
    updated: .fields.updated,
    description: (if .fields.description then "..." else null end)
}'

if [ "$SHOW_COMMENTS" = "true" ]; then
    COMMENTS=$("$SCRIPT_DIR/jira-api.sh" GET "/rest/api/3/issue/${ISSUE}/comment" 2>&1)
    if [ $? -ne 0 ]; then
        echo "WARNING: Could not fetch comments: ${COMMENTS}" >&2
    else
        echo ""
        echo "$COMMENTS" | jq '[.comments[] | {
            author: .author.displayName,
            created: .created,
            body: (if .body.content then [.body.content[].content[]?.text] | join(" ") else .body end)
        }]'
    fi
fi
