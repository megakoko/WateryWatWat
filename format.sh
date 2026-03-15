#!/bin/sh

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: uncommitted changes present"
    exit 1
fi

swiftformat . --quiet

if ! git diff --quiet; then
    git add -A
    git commit -q -m "Formatting"
    echo "Formatted and committed changes"
else
    echo "No formatting necessary"
fi
