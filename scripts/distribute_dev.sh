#!/bin/bash
set -e

FIREBASE_APP_ID="1:481799697583:android:7a1a6beccacf3956a4505a"
PUBSPEC="$(dirname "$0")/../pubspec.yaml"

# Bump patch and build number
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3 | cut -d+ -f1)
BUILD=$(echo "$CURRENT" | cut -d+ -f2)

NEW_PATCH=$((PATCH + 1))
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH+$NEW_BUILD"

sed -i "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
echo "Version bumped to $NEW_VERSION"

echo "Running flutter clean..."
flutter clean

echo "Running flutter pub get..."
flutter pub get

echo "Building dev APK..."
flutter build apk --flavor dev --target lib/main_dev.dart --release

echo "Distributing to Firebase App Distribution..."
firebase appdistribution:distribute \
  build/app/outputs/apk/dev/release/app-dev-release.apk \
  --app "$FIREBASE_APP_ID" \
  --release-notes "Dev build $NEW_VERSION" \
  --groups "testers"

echo "Done. Testers will receive an email with the download link."
