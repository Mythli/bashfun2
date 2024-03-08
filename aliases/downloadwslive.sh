#!/bin/bash
set -e
set -x

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <remote_directory> <local_directory>"
    exit 1
fi

# Assign arguments to variables
REMOTE_DIR=$1
LOCAL_DIR=$2
REMOTE_HOST="root@138.201.57.185" # Replace with your actual username and server IP

# Use rsync to download the directory
rsync -avz -e ssh --progress "$REMOTE_HOST":"$REMOTE_DIR" "$LOCAL_DIR"

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Directory downloaded successfully."
else
    echo "An error occurred during rsync."
    exit 1
fi