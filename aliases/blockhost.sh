#!/bin/bash

# Check if sufficient parameters are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <focus,unfocus,work> <content>"
    exit 1
fi

# Configurable base folder
BASE_FOLDER="/Users/tobiasanhalt/Development/bashfun/aliases/hosts"

# Compute the absolute path of the file
TARGET_FILE="$BASE_FOLDER/$1"

# Check if the target file exists
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Error: File $TARGET_FILE does not exist!"
    exit 1
fi

# Append content to the target file
echo "127.0.0.1 $2" >> "$TARGET_FILE"

# Append content to /etc/hosts
echo "127.0.0.1 $2" >> /etc/hosts

echo "Content added successfully!"
