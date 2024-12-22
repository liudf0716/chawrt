#!/bin/bash
set -e

# step 1: fetch origin
if ! git fetch origin; then
    echo "Failed to fetch from origin"
    exit 1
fi

for branch in $branches
do
    echo "Syncing branch $branch..."
    git checkout $branch
    if ! git checkout "$branch"; then
        echo "Failed to checkout branch $branch"
        continue
    fi
    
    echo "Prompt user the following operation will reset hard origin/$branch"
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        git reset --hard origin/$branch
    fi
done