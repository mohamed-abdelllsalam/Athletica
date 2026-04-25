#!/bin/bash
set -e

FIREBASE_APP_ID="1:481799697583:android:7a1a6beccacf3956a4505a"

echo "Building dev APK..."
flutter build apk --flavor dev --target lib/main_dev.dart --release

echo "Distributing to Firebase App Distribution..."
firebase appdistribution:distribute \
  build/app/outputs/apk/dev/release/app-dev-release.apk \
  --app "$FIREBASE_APP_ID" \
  --release-notes "$(git log -1 --pretty=%B)" \
  --groups "testers"

echo "Done. Testers will receive an email with the download link."
