$ErrorActionPreference = "Stop"

$FIREBASE_APP_ID = "1:481799697583:android:7a1a6beccacf3956a4505a"
$PUBSPEC = Resolve-Path (Join-Path $PSScriptRoot "..\pubspec.yaml")

# Read file as bytes to avoid BOM/encoding issues
$rawBytes = [System.IO.File]::ReadAllBytes($PUBSPEC)
$content = [System.Text.Encoding]::UTF8.GetString($rawBytes)

# Strip UTF-8 BOM if present
if ($content.StartsWith([char]0xFEFF)) {
    $content = $content.Substring(1)
}

# Bump patch and build number
if ($content -match 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3] + 1
    $build = [int]$Matches[4] + 1
    $newVersion = "$major.$minor.$patch+$build"
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersion"
    $newBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    [System.IO.File]::WriteAllBytes($PUBSPEC, $newBytes)
    Write-Host "Version bumped to $newVersion"
} else {
    Write-Error "Could not parse version from pubspec.yaml"
    exit 1
}

Write-Host "Running flutter clean..."
flutter clean
if ($LASTEXITCODE -ne 0) { Write-Error "flutter clean failed"; exit 1 }

Write-Host "Running flutter pub get..."
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Error "flutter pub get failed"; exit 1 }

Write-Host "Building dev APK..."
flutter build apk --flavor dev --target lib/main_dev.dart --release
if ($LASTEXITCODE -ne 0) { Write-Error "flutter build failed"; exit 1 }

Write-Host "Distributing to Firebase..."
firebase appdistribution:distribute `
  build/app/outputs/apk/dev/release/app-dev-release.apk `
  --app $FIREBASE_APP_ID `
  --release-notes "Dev build $newVersion" `
  --groups "testers"
if ($LASTEXITCODE -ne 0) { Write-Error "Firebase distribution failed"; exit 1 }

Write-Host "Done. Testers will receive an email with the download link."
