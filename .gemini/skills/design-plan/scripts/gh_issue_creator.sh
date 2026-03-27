#!/bin/bash

# Simple wrapper for GitHub CLI issue creation.
# Usage: ./gh_issue_creator.sh "Title" "Body" "Label"

TITLE=$1
BODY=$2
LABEL=$3

if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    exit 1
fi

# Dry run by default if not told otherwise, or just output the command.
echo "gh issue create --title \"$TITLE\" --body \"$BODY\" --label \"$LABEL\""
