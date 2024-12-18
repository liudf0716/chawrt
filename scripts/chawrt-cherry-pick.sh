#!/bin/bash

# This script is used to cherry-pick a commit from the current branch to another branch.
# Usage: chawrt-cherry-pick.sh <commit> <branch>
# Example: chawrt-cherry-pick.sh 1234567 master

# Check if the correct number of arguments is provided
if [ "$#" -eq 1 ]; then
    BRANCH=$1
    COMMIT=$(git rev-parse HEAD)
elif [ "$#" -eq 2 ]; then
    BRANCH=$1
    COMMIT=$2
else
    echo "Usage: $0 <branch> [<commit>]"
    echo "If commit is not specified, the first commit of current branch will be used."
    exit 1
fi

# Ensure the repository is clean
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them before running this script."
    exit 1
fi

# Check if the branch exists
if ! git show-ref --verify --quiet refs/heads/$BRANCH; then
    echo "Error: Branch '$BRANCH' does not exist."
    exit 1
fi

# Check if the commit exists
if ! git cat-file -e ${COMMIT}^{commit} 2>/dev/null; then
    echo "Error: Commit '$COMMIT' does not exist."
    exit 1
fi

# Store the original branch name before switching
ORIGINAL_BRANCH=$(git symbolic-ref --short HEAD)
echo "Original branch: $ORIGINAL_BRANCH"

# Switch to the target branch
echo "Switching to branch '$BRANCH'..."
git checkout $BRANCH || exit 1

# Cherry-pick the commit
echo "Cherry-picking commit '$COMMIT'..."
if git cherry-pick $COMMIT; then
    echo "Successfully cherry-picked commit '$COMMIT' to branch '$BRANCH'."
else
    echo "Error: Cherry-pick failed. Resolve conflicts and run 'git cherry-pick --continue' or 'git cherry-pick --abort'."
fi

git checkout $ORIGINAL_BRANCH || exit 1

echo "Done."