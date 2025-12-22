#!/bin/bash

set -e

if ! git diff --quiet -- WateryWatWat.xcodeproj; then
    echo "Error: WateryWatWat.xcodeproj has uncommitted changes"
    exit 1
fi

agvtool next-version -all

VERSION=$(grep -m 1 "MARKETING_VERSION = " WateryWatWat.xcodeproj/project.pbxproj | awk -F' = ' '{print $2}' | tr -d ';')
BUILD=$(agvtool what-version -terse)

git add WateryWatWat.xcodeproj
git commit -m "Build ${VERSION} (${BUILD})"

echo "Incremented to version ${VERSION} (${BUILD})"
