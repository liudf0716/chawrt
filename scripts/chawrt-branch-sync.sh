#!/bin/bash
set -e

# step 1: fetch origin
if ! git fetch origin; then
    echo "Failed to fetch from origin"
    exit 1
fi

branches=$(git branch | tr -d ' *')

# step 2: sync branches
for branch in $branches; do
    echo "Syncing branch: $branch"
    if ! git checkout "$branch"; then
        echo "Failed to checkout branch: $branch"
        exit 1
    fi

    if ! git rebase  "origin/$branch"; then
        echo "Failed to pull branch: $branch"
        exit 1
    fi
done