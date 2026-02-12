#!/bin/bash

EXPECTED_OUTPUT="$1"
OUTPUT_FILE="$2"
DEADLINE="2026-02-12 10:00:00 -0600"
START_DIR="$(pwd)"

while read -r KEY; do
    GRADE=0
    REPO_URL="https://github.com/CSE2307SP26/${KEY}.git"

    rm -rf "$KEY"

    if ! git clone -q "$REPO_URL"; then
        echo "$KEY 0"
        continue
    fi

    cd "$KEY" || { echo "$KEY 0"; cd "$START_DIR"; continue; }

    git checkout -q cipher

    COMMIT=$(git rev-list -n 1 --before="$DEADLINE" HEAD)
    if [ -z "$COMMIT" ]; then
        echo "$KEY 0"
        cd "$START_DIR"
        continue
    fi

    git checkout -q "$COMMIT"

    if ! javac Cipher.java >/dev/null 2>&1; then
        echo "$KEY 0"
        cd "$START_DIR"
        continue
    fi

    # BOTH class names?...
    if java Cipher > "$OUTPUT_FILE" 2>/dev/null; then
        :
    elif java cipher > "$OUTPUT_FILE" 2>/dev/null; then
        :
    else
        echo "$KEY 0"
        cd "$START_DIR"
        continue
    fi

    if diff -q "$OUTPUT_FILE" "$START_DIR/$EXPECTED_OUTPUT" >/dev/null 2>&1; then
        GRADE=1
    fi

    echo "$KEY $GRADE"
    cd "$START_DIR"
done
