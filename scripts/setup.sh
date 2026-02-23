#!/usr/bin/env bash
set -euo pipefail

# AI-Native Development Bootstrap - Project Setup Script
# Usage: ./scripts/setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# --- Prerequisites ---

check_prerequisites() {
    local missing=0

    if ! command -v git &>/dev/null; then
        error "git is not installed. Please install git first."
        missing=1
    fi

    if ! command -v sed &>/dev/null; then
        error "sed is not installed."
        missing=1
    fi

    if [ "$missing" -ne 0 ]; then
        exit 1
    fi

    info "All prerequisites met."
}

# --- Input helpers ---

prompt_input() {
    local prompt="$1"
    local varname="$2"
    local default="${3:-}"
    local value=""

    if [ -n "$default" ]; then
        read -rp "$prompt [$default]: " value
        value="${value:-$default}"
    else
        while [ -z "$value" ]; do
            read -rp "$prompt: " value
            if [ -z "$value" ]; then
                warn "This field is required."
            fi
        done
    fi

    eval "$varname='$value'"
}

validate_project_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        error "Invalid project name: '$name'"
        error "Must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens."
        return 1
    fi
    return 0
}

# --- Placeholder replacement ---

replace_placeholder() {
    local file="$1"
    local placeholder="$2"
    local value="$3"

    if [ ! -f "$file" ]; then
        warn "File not found, skipping: $file"
        return 0
    fi

    if grep -q "$placeholder" "$file" 2>/dev/null; then
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' "s|${placeholder}|${value}|g" "$file"
        else
            sed -i "s|${placeholder}|${value}|g" "$file"
        fi
        info "Updated $file"
    fi
}

replace_all_placeholders() {
    local name="$1"
    local stack="$2"
    local description="$3"

    local files=(
        "$PROJECT_ROOT/CLAUDE.md"
        "$PROJECT_ROOT/README.md"
        "$PROJECT_ROOT/docs/architecture.md"
        "$PROJECT_ROOT/docs/constitution.md"
    )

    for file in "${files[@]}"; do
        replace_placeholder "$file" "{{PROJECT_NAME}}" "$name"
        replace_placeholder "$file" "{{TECH_STACK}}" "$stack"
        replace_placeholder "$file" "{{PROJECT_DESCRIPTION}}" "$description"
        replace_placeholder "$file" "{{TECH_STACK}}" "$stack"
    done
}

# --- Git hooks ---

setup_git_hooks() {
    if command -v pre-commit &>/dev/null; then
        info "Setting up pre-commit hooks..."
        if [ -f "$PROJECT_ROOT/.pre-commit-config.yaml" ]; then
            (cd "$PROJECT_ROOT" && pre-commit install)
            info "Pre-commit hooks installed."
        fi
    else
        warn "pre-commit not found. Skipping hook setup."
        warn "Install with: pip install pre-commit"
    fi
}

# --- Main ---

main() {
    echo ""
    echo "=========================================="
    echo "  AI-Native Development Bootstrap Setup"
    echo "=========================================="
    echo ""

    check_prerequisites

    # Gather input
    local project_name=""
    while true; do
        prompt_input "Project name (lowercase, hyphens ok)" project_name
        if validate_project_name "$project_name"; then
            break
        fi
    done

    local tech_stack=""
    prompt_input "Tech stack (e.g., Next.js + TypeScript + Prisma)" tech_stack

    local description=""
    prompt_input "One-line project description" description

    echo ""
    info "Configuring project: $project_name"

    # Apply placeholders
    replace_all_placeholders "$project_name" "$tech_stack" "$description"

    # Git hooks
    setup_git_hooks

    echo ""
    echo "=========================================="
    echo "  Setup Complete!"
    echo "=========================================="
    echo ""
    info "Project:     $project_name"
    info "Stack:       $tech_stack"
    info "Description: $description"
    echo ""
    echo "Next steps:"
    echo "  1. Review CLAUDE.md and adjust AI coding guidelines"
    echo "  2. Review docs/constitution.md and customize project principles"
    echo "  3. Review docs/architecture.md and add system details"
    echo "  4. Start building!"
    echo ""
}

main "$@"
