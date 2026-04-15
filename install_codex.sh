#!/bin/bash

# CKB Dev Skill Installer for Codex
# Usage: ./install_codex.sh [--project | --path <path>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="ckb-dev"
SOURCE_DIR="$SCRIPT_DIR/skill"

# Default to personal installation
INSTALL_PATH="$HOME/.codex/skills/$SKILL_NAME"

resolve_install_path() {
    local target="$1"
    local parent
    local base

    parent="$(dirname "$target")"
    base="$(basename "$target")"

    mkdir -p "$parent"
    parent="$(cd "$parent" && pwd -P)"

    printf '%s/%s\n' "$parent" "$base"
}

validate_install_path() {
    local target="$1"
    local base
    local cwd

    cwd="$(pwd -P)"
    base="$(basename "$target")"

    if [[ -z "$target" || "$target" == "/" || "$base" == "." || "$base" == ".." ]]; then
        echo "Error: Refusing to install into an unsafe path"
        exit 1
    fi

    case "$target" in
        "$HOME"|"$HOME/.codex"|"$HOME/.codex/skills"|"$SCRIPT_DIR"|"$SOURCE_DIR"|"$cwd")
            echo "Error: Refusing to install into unsafe path '$target'"
            exit 1
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            INSTALL_PATH=".codex/skills/$SKILL_NAME"
            shift
            ;;
        --path)
            if [ $# -lt 2 ] || [[ -z "$2" ]] || [[ "$2" == -* ]]; then
                echo "Error: --path requires a destination path"
                exit 1
            fi
            INSTALL_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "CKB Dev Skill Installer for Codex"
            echo ""
            echo "Usage: ./install_codex.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --project     Install to current project (.codex/skills/$SKILL_NAME)"
            echo "  --path PATH   Install to custom path"
            echo "  -h, --help    Show this help message"
            echo ""
            echo "Default: Install to ~/.codex/skills/$SKILL_NAME"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

INSTALL_PATH="$(resolve_install_path "$INSTALL_PATH")"
validate_install_path "$INSTALL_PATH"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found"
    exit 1
fi

# Check if SKILL.md exists
if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
    echo "Error: SKILL.md not found in '$SOURCE_DIR'"
    exit 1
fi

# Create parent directory if needed
mkdir -p "$(dirname "$INSTALL_PATH")"

# Refuse to overwrite a non-directory target
if [ -e "$INSTALL_PATH" ] && [ ! -d "$INSTALL_PATH" ]; then
    echo "Error: '$INSTALL_PATH' exists and is not a directory"
    exit 1
fi

# Check if destination already exists
if [ -d "$INSTALL_PATH" ]; then
    echo "Warning: '$INSTALL_PATH' already exists"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    rm -rf -- "$INSTALL_PATH"
fi

# Copy skill files
echo "Installing CKB Dev Skill for Codex..."
cp -r "$SOURCE_DIR" "$INSTALL_PATH"

echo ""
echo "Successfully installed to: $INSTALL_PATH"
echo ""
echo "Installed files:"
find "$INSTALL_PATH" -type f -name "*.md" | sort | while read -r file; do
    echo "  - $(basename "$file")"
done
echo ""
echo "The skill is now available in Codex."
echo "Try asking about CKB development to activate it!"
echo ""
echo "Using another AI agent? Point it at this folder (or link/symlink it):"
echo "  $INSTALL_PATH"
