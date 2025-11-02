#!/usr/bin/env bash

# Specify the location of the Git directory outside of the container
GIT_DIR="$(dirname "$(realpath "$0")")/../.."

# Navigate to the Git directory
cd "$GIT_DIR" || exit

# Get the current commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Reset the HEAD to the commit hash
sudo git reset --hard "$COMMIT_HASH"

echo "HEAD reference fixed in Git directory: $GIT_DIR"
