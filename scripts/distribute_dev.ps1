$ErrorActionPreference = "Stop"

$FIREBASE_APP_ID = "1:481799697583:android:7a1a6beccacf3956a4505a"

Write-Host "Building dev APK..."
flutter build apk --flavor dev --target lib/main_dev.dart --release

Write-Host "Distributing to Firebase..."
firebase appdistribution:distribute `
  build/app/outputs/apk/dev/release/app-dev-release.apk `
  --app $FIREBASE_APP_ID `
  --release-notes "Dev build" `
  --groups "testers"

Write-Host "Done. Testers will receive an email with the download link."
