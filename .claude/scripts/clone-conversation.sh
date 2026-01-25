#!/usr/bin/env bash
#
# clone-conversation.sh - Clone a Claude Code conversation
#
# Pure bash implementation - no Python/Node dependencies.
# Works on macOS (bash 3.2+) and Linux.
#
# Usage:
#   clone-conversation.sh <session-id> [project-path]
#
# Arguments:
#   session-id    The UUID of the conversation to clone (required)
#   project-path  The project path (default: current directory)
#
# Example:
#   clone-conversation.sh d96c899d-7501-4e81-a31b-e0095bb3b501
#   clone-conversation.sh d96c899d-7501-4e81-a31b-e0095bb3b501 /home/user/myproject
#
# After cloning, use 'claude -r' to see both the original and cloned conversation.
#

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
PROJECTS_DIR="${CLAUDE_DIR}/projects"
HISTORY_FILE="${CLAUDE_DIR}/history.jsonl"
TODOS_DIR="${CLAUDE_DIR}/todos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
    echo "Usage: $0 <session-id> [project-path]"
    echo ""
    echo "Arguments:"
    echo "  session-id    The UUID of the conversation to clone (required)"
    echo "  project-path  The project path (default: current directory)"
    exit 1
}

# UUID generation - works on both Mac and Linux
generate_uuid() {
    if command -v uuidgen &> /dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback using $RANDOM
        printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
            $((RANDOM)) $((RANDOM)) $((RANDOM)) \
            $((RANDOM & 0x0fff | 0x4000)) \
            $((RANDOM & 0x3fff | 0x8000)) \
            $((RANDOM)) $((RANDOM)) $((RANDOM))
    fi
}

convert_path_to_dirname() {
    echo "$1" | sed 's|^/||' | sed 's|/|-|g' | sed 's|^|-|'
}

find_conversation_file() {
    local session_id="$1"
    local project_path="$2"
    local project_dirname
    project_dirname=$(convert_path_to_dirname "$project_path")
    local project_dir="${PROJECTS_DIR}/${project_dirname}"
    local conv_file="${project_dir}/${session_id}.jsonl"

    if [ -f "$conv_file" ]; then
        echo "$conv_file"
        return 0
    fi

    # Try to find in any project directory
    local found_file
    found_file=$(find "$PROJECTS_DIR" -name "${session_id}.jsonl" 2>/dev/null | head -1)

    if [ -n "$found_file" ]; then
        echo "$found_file"
        return 0
    fi

    return 1
}

get_project_from_conv_file() {
    local conv_file="$1"
    local project_dirname
    project_dirname=$(dirname "$conv_file" | xargs basename)
    echo "$project_dirname" | sed 's|^-|/|' | sed 's|-|/|g'
}

# UUID mapping using temp file (works around subshell issues)
UUID_MAP_FILE=""

init_uuid_map() {
    UUID_MAP_FILE=$(mktemp)
}

cleanup_uuid_map() {
    [ -n "$UUID_MAP_FILE" ] && [ -f "$UUID_MAP_FILE" ] && rm -f "$UUID_MAP_FILE"
}

get_mapped_uuid() {
    local old_uuid="$1"

    # Check if we already have a mapping
    local existing
    existing=$(grep "^${old_uuid}:" "$UUID_MAP_FILE" 2>/dev/null | cut -d: -f2 || true)
    if [ -n "$existing" ]; then
        echo "$existing"
        return
    fi

    # Generate new UUID and store mapping
    local new_uuid
    new_uuid=$(generate_uuid)
    echo "${old_uuid}:${new_uuid}" >> "$UUID_MAP_FILE"
    echo "$new_uuid"
}

# Extract UUID value from a JSON key-value pattern like "uuid":"value"
extract_uuid_value() {
    local line="$1"
    local key="$2"
    # Extract the value after "key":"
    echo "$line" | grep -oE "\"${key}\":\"[a-f0-9-]{36}\"" 2>/dev/null | head -1 | sed "s/\"${key}\":\"//;s/\"//" || true
}

# Replace a UUID value in the line
replace_uuid_in_line() {
    local line="$1"
    local key="$2"
    local old_val="$3"
    local new_val="$4"
    echo "$line" | sed "s|\"${key}\":\"${old_val}\"|\"${key}\":\"${new_val}\"|g"
}

# Process a single JSONL line
process_line() {
    local line="$1"
    local new_session="$2"
    local is_first_user="$3"
    local clone_tag="$4"
    local result="$line"

    # Replace sessionId
    local old_session
    old_session=$(extract_uuid_value "$result" "sessionId")
    if [ -n "$old_session" ]; then
        result=$(replace_uuid_in_line "$result" "sessionId" "$old_session" "$new_session")
    fi

    # Replace uuid field (not parentUuid, not sessionId)
    local old_uuid
    old_uuid=$(echo "$result" | grep -oE '"uuid":"[a-f0-9-]{36}"' 2>/dev/null | head -1 | sed 's/"uuid":"//;s/"//' || true)
    if [ -n "$old_uuid" ]; then
        local new_uuid
        new_uuid=$(get_mapped_uuid "$old_uuid")
        result=$(replace_uuid_in_line "$result" "uuid" "$old_uuid" "$new_uuid")
    fi

    # Replace parentUuid
    local old_parent
    old_parent=$(extract_uuid_value "$result" "parentUuid")
    if [ -n "$old_parent" ]; then
        local new_parent
        new_parent=$(get_mapped_uuid "$old_parent")
        result=$(replace_uuid_in_line "$result" "parentUuid" "$old_parent" "$new_parent")
    fi

    # Replace messageId
    local old_msgid
    old_msgid=$(extract_uuid_value "$result" "messageId")
    if [ -n "$old_msgid" ]; then
        local new_msgid
        new_msgid=$(get_mapped_uuid "$old_msgid")
        result=$(replace_uuid_in_line "$result" "messageId" "$old_msgid" "$new_msgid")
    fi

    # Tag first user message with clone tag
    if [ "$is_first_user" = "true" ]; then
        if echo "$result" | grep -q '"type":"user"' 2>/dev/null; then
            # Handle string content: "content":"text" -> "content":"[CLONED ...] text"
            result=$(echo "$result" | sed "s/\"content\":\"/\"content\":\"${clone_tag} /")
            # Handle array content: "text":"..." -> "text":"[CLONED ...] ..."
            result=$(echo "$result" | sed "s/\"text\":\"/\"text\":\"${clone_tag} /")
        fi
    fi

    echo "$result"
}

clone_conversation() {
    local source_session="$1"
    local project_path="$2"

    # Generate timestamp for clone tag (e.g., "Jan 7 14:30")
    local clone_timestamp
    clone_timestamp=$(date "+%b %-d %H:%M")
    local clone_tag="[CLONED ${clone_timestamp}]"

    # Find source file
    local source_file
    if ! source_file=$(find_conversation_file "$source_session" "$project_path"); then
        log_error "Could not find conversation file for session: $source_session"
        log_info "Looking in: ${PROJECTS_DIR}"
        log_info "Available conversations:"
        find "$PROJECTS_DIR" -name "*.jsonl" -type f 2>/dev/null | while read -r f; do
            local fname
            fname=$(basename "$f")
            if [[ ${#fname} -eq 42 && "$fname" =~ ^[a-f0-9-]+\.jsonl$ ]]; then
                echo "  - ${fname%.jsonl}"
            fi
        done
        exit 1
    fi

    log_info "Found source conversation: $source_file"

    if [ -z "$project_path" ]; then
        project_path=$(get_project_from_conv_file "$source_file")
    fi

    # Generate new session ID
    local new_session
    new_session=$(generate_uuid)
    log_info "Generated new session ID: $new_session"

    # Target file
    local project_dirname
    project_dirname=$(convert_path_to_dirname "$project_path")
    local project_dir="${PROJECTS_DIR}/${project_dirname}"
    local target_file="${project_dir}/${new_session}.jsonl"

    mkdir -p "$project_dir"
    log_info "Cloning conversation to: $target_file"

    # Initialize UUID mapping
    init_uuid_map
    trap cleanup_uuid_map EXIT

    # Process the file
    local first_user_found="false"
    local line_count=0

    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue

        local is_first_user="false"
        if [ "$first_user_found" = "false" ] && echo "$line" | grep -q '"type":"user"' 2>/dev/null; then
            is_first_user="true"
            first_user_found="true"
        fi

        process_line "$line" "$new_session" "$is_first_user" "$clone_tag"
        ((line_count++)) || true
    done < "$source_file" > "$target_file"

    echo "SUCCESS: Wrote $line_count lines to $target_file"

    # Update history.jsonl
    log_info "Updating history file..."

    # Get display text from first user message
    local display_text
    display_text=$(grep '"type":"user"' "$source_file" | head -1 | \
        grep -oE '"content":"[^"]*"' | head -1 | \
        sed 's/"content":"//;s/"$//' | \
        head -c 200 || echo "[Cloned conversation]")

    if [ -z "$display_text" ]; then
        # Try array format
        display_text=$(grep '"type":"user"' "$source_file" | head -1 | \
            grep -oE '"text":"[^"]*"' | head -1 | \
            sed 's/"text":"//;s/"$//' | \
            head -c 200 || echo "[Cloned conversation]")
    fi

    display_text="${clone_tag} ${display_text}"

    # Timestamp (milliseconds)
    local timestamp
    if [[ "$OSTYPE" == "darwin"* ]]; then
        timestamp=$(( $(date +%s) * 1000 + 1000 ))
    else
        timestamp=$(( $(date +%s%3N) + 1000 ))
    fi

    # Escape for JSON
    display_text=$(echo "$display_text" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')

    # Add history entry
    echo "{\"display\":\"${display_text}\",\"pastedContents\":{},\"timestamp\":${timestamp},\"project\":\"${project_path}\",\"sessionId\":\"${new_session}\"}" >> "$HISTORY_FILE"
    echo "History entry added successfully"

    # Copy todos if they exist
    local old_todo_file="${TODOS_DIR}/${source_session}-agent-${source_session}.json"
    local new_todo_file="${TODOS_DIR}/${new_session}-agent-${new_session}.json"

    if [ -f "$old_todo_file" ]; then
        log_info "Copying todo file..."
        cp "$old_todo_file" "$new_todo_file"
    fi

    log_success "Conversation cloned successfully!"
    echo ""
    echo "Original session: $source_session"
    echo "New session:      $new_session"
    echo "Project:          $project_path"
    echo ""
    echo "To resume the cloned conversation, use:"
    echo "  claude -r"
    echo ""
    echo "Then select the conversation marked with ${clone_tag}"
}

# Main
if [ $# -lt 1 ]; then
    usage
fi

SESSION_ID="$1"
PROJECT_PATH="${2:-$(pwd)}"

# Validate session ID
if ! [[ "$SESSION_ID" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
    log_error "Invalid session ID format. Expected UUID like: d96c899d-7501-4e81-a31b-e0095bb3b501"
    exit 1
fi

if [ ! -d "$CLAUDE_DIR" ]; then
    log_error "Claude directory not found at $CLAUDE_DIR"
    exit 1
fi

clone_conversation "$SESSION_ID" "$PROJECT_PATH"
