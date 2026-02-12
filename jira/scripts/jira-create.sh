#!/bin/bash
# Create a Jira issue
# Usage: jira-create.sh --type <type> --summary "title" [options]
#
# Options:
#   --type TYPE           Issue type (required) — run jira-meta.sh types to see valid values
#   --summary "text"      Issue title (required)
#   --description "text"  Description
#   --project KEY         Project key (uses default from config if not set)
#   --assignee ID         Assignee account ID or username
#   --priority NAME       Priority — run jira-meta.sh priorities to see valid values
#   --labels "l1 l2"      Space-separated labels (in addition to defaults)
#   --parent KEY          Parent issue key (for sub-tasks)
#
# Outputs the created issue key (e.g. PROJ-123)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/_config.sh"

TYPE="" SUMMARY="" DESCRIPTION="" PROJECT="${JIRA_PROJECT}" ASSIGNEE="${JIRA_ASSIGNEE}"
PRIORITY="" LABELS="" PARENT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --type)        TYPE="$2";        shift 2 ;;
        --summary)     SUMMARY="$2";     shift 2 ;;
        --description) DESCRIPTION="$2"; shift 2 ;;
        --project)     PROJECT="$2";     shift 2 ;;
        --assignee)    ASSIGNEE="$2";    shift 2 ;;
        --priority)    PRIORITY="$2";    shift 2 ;;
        --labels)      LABELS="$2";      shift 2 ;;
        --parent)      PARENT="$2";      shift 2 ;;
        *)
            cat >&2 << EOF
ERROR: Unknown option '$1'.

Valid options:
  --type TYPE           Issue type (required)
  --summary "text"      Issue title (required)
  --description "text"  Description body
  --project KEY         Project key (default: ${JIRA_PROJECT:-not set})
  --assignee ID         Assignee username
  --priority NAME       Priority name
  --labels "l1 l2"      Additional labels (space-separated)
  --parent KEY          Parent issue for sub-tasks

Example:
  jira-create.sh --type Bug --summary "Login fails on timeout" --priority High
EOF
            exit 1
            ;;
    esac
done

if [ -z "$TYPE" ]; then
    cat >&2 << EOF
ERROR: --type is required.

You must specify an issue type. To see valid issue types for your project, run:
  $SCRIPT_DIR/jira-meta.sh types${PROJECT:+ --project ${PROJECT}}

Example:
  jira-create.sh --type Bug --summary "Title here"
EOF
    exit 1
fi

if [ -z "$SUMMARY" ]; then
    cat >&2 << EOF
ERROR: --summary is required.

Every issue needs a title. Provide it with --summary.

Example:
  jira-create.sh --type ${TYPE} --summary "Fix timeout in login flow"
EOF
    exit 1
fi

if [ -z "$PROJECT" ]; then
    cat >&2 << EOF
ERROR: No project specified and no default configured.

Provide a project with --project KEY, or set a default:
  echo "JIRA_PROJECT=PROJ" >> ~/.boring/jira/defaults

You can also set it during setup by running the boring-skills setup script (setup.sh).
EOF
    exit 1
fi

# Validate issue type against project metadata
_validate_type() {
    local cache="$HOME/.boring/jira/cache/types_${PROJECT}.json"

    # Fetch cache if missing
    if [ ! -f "$cache" ]; then
        "$SCRIPT_DIR/jira-meta.sh" types --project "$PROJECT" > /dev/null 2>&1 || true
    fi

    if [ -f "$cache" ] && [ -s "$cache" ]; then
        if ! jq -e --arg t "$TYPE" 'map(.name) | index($t)' "$cache" >/dev/null 2>&1; then
            local valid
            valid=$(jq -r '[.[] | "  - " + .name + (if .description != "" then " (" + .description + ")" else "" end)] | join("\n")' "$cache" 2>/dev/null)
            cat >&2 << EOF
ERROR: Issue type '${TYPE}' does not exist in project ${PROJECT}.

Available issue types for ${PROJECT}:
${valid}

Pick one of the types listed above and retry. Example:
  jira-create.sh --type "Bug" --summary "${SUMMARY}"

To refresh the cached types:
  $SCRIPT_DIR/jira-meta.sh refresh --project ${PROJECT}
EOF
            exit 1
        fi
    fi
}
_validate_type

# Build go-jira create command
CMD=(jira create --noedit -p "$PROJECT" -i "$TYPE" -o "summary=${SUMMARY}")

[ -n "$DESCRIPTION" ] && CMD+=(-o "description=${DESCRIPTION}")
[ -n "$ASSIGNEE" ]    && CMD+=(-o "assignee=${ASSIGNEE}")
[ -n "$PRIORITY" ]    && CMD+=(-o "priority=${PRIORITY}")
[ -n "$PARENT" ]      && CMD+=(-o "parent={\"key\":\"${PARENT}\"}")

# Create the issue and extract key
# go-jira outputs "OK PROJ-123 https://...PROJ-123" — grep matches the key twice.
# Use head -1 to take only the first match.
OUTPUT=$("${CMD[@]}" 2>&1)
# Jira project keys: start with uppercase, can contain digits/underscores (e.g., APP1-123, P2P-456)
ISSUE_KEY=$(echo "$OUTPUT" | grep -oE '[A-Z][A-Z0-9_]+-[0-9]+' | head -1)

if [ -z "$ISSUE_KEY" ]; then
    cat >&2 << EOF
ERROR: Failed to create issue. go-jira returned:
  ${OUTPUT}

Common causes:
  - Required field missing: some projects require extra fields (e.g. components, fix version).
    Check with: $SCRIPT_DIR/jira-meta.sh fields
  - Permission denied: your user may not have create permission in project ${PROJECT}.
  - Invalid priority: run $SCRIPT_DIR/jira-meta.sh priorities to see valid values.
  - Auth expired: test with $SCRIPT_DIR/jira-api.sh GET /rest/api/3/myself

The go-jira command that was run:
  ${CMD[*]}
EOF
    exit 1
fi

# Apply default labels + extra labels.
# Default labels from ~/.boring/jira/default-labels are ALWAYS applied unless --no-labels is used.
# This is intentional — labels are required for ticket tracking and filtering.
ALL_LABELS="${JIRA_DEFAULT_LABELS}"
if [ -n "$LABELS" ]; then
    if [ -n "$ALL_LABELS" ]; then
        ALL_LABELS="${ALL_LABELS} ${LABELS}"
    else
        ALL_LABELS="${LABELS}"
    fi
fi

if [ -n "$ALL_LABELS" ]; then
    LABEL_OUTPUT=$(jira labels set "$ISSUE_KEY" $ALL_LABELS 2>&1)
    LABEL_RC=$?
    if [ $LABEL_RC -ne 0 ]; then
        # Labels are mandatory. This is a hard failure — the LLM must fix it.
        cat >&2 << EOF
ERROR: Issue ${ISSUE_KEY} was created BUT labels could not be applied.

Labels that MUST be set: ${ALL_LABELS}
go-jira returned (exit ${LABEL_RC}): ${LABEL_OUTPUT}

YOU MUST FIX THIS NOW. Run this command to apply the labels:
  jira labels set ${ISSUE_KEY} ${ALL_LABELS}

Or via the script:
  $SCRIPT_DIR/jira-labels.sh ${ISSUE_KEY} set ${ALL_LABELS}

If that also fails, use the raw API:
  $SCRIPT_DIR/jira-api.sh PUT "/rest/api/3/issue/${ISSUE_KEY}" '{"update":{"labels":[$(echo "$ALL_LABELS" | tr ' ' '\n' | sed 's/.*/ {"add":"&"}/' | paste -sd, -)]}}'

Do NOT leave the issue without labels. Labels are required for tracking.
The issue key is: ${ISSUE_KEY}
EOF
        echo "$ISSUE_KEY"
        exit 1
    fi
fi

echo "$ISSUE_KEY"
