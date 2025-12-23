#!/bin/bash

set -e

cd "$(dirname "$0")"

SCHEME="WateryWatWat"
ARCHIVE_PATH="_build/WateryWatWat.xcarchive"
EXPORT_PATH="_build/export"

echo "Incrementing build number..."
./increment-build.sh

echo "Cleaning build folder..."
rm -rf _build
mkdir -p _build

echo "Archiving..."
xcodebuild archive \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS"

echo "Exporting for App Store..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist exportOptions.plist

echo "Uploading to App Store Connect..."
xcrun altool --upload-app \
    --type ios \
    --file "$EXPORT_PATH/$SCHEME.ipa" \
    --apiKey 292QX9BD57 \
    --apiIssuer 50663529-9ab7-400d-8262-83e8e21311f9

echo "Build published successfully!"
