#!/bin/bash

set -e

if ! git diff --quiet -- WateryWatWat.xcodeproj; then
    echo "Error: WateryWatWat.xcodeproj has uncommitted changes"
    exit 1
fi

agvtool next-version -all

VERSION=$(agvtool what-marketing-version -terse1)
BUILD=$(agvtool what-version -terse)

git add WateryWatWat.xcodeproj
git commit -m "Incremented version ${VERSION} (${BUILD})"

echo "Incremented to version ${VERSION} (${BUILD})"
