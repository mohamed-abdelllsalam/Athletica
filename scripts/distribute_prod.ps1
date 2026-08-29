$ErrorActionPreference = "Stop"

$FIREBASE_APP_ID = "1:481799697583:android:9b6aa441decae0c5a4505a"
$PUBSPEC = Resolve-Path (Join-Path $PSScriptRoot "..\pubspec.yaml")

# Read with BOM detection to avoid corrupting the first character
$reader = New-Object System.IO.StreamReader($PUBSPEC, $true)
$content = $reader.ReadToEnd()
$encoding = $reader.CurrentEncoding
$reader.Close()

# Strip UTF-8 BOM if present
if ($content.StartsWith([char]0xFEFF)) {
    $content = $content.Substring(1)
}

# Ensure the required name field exists and is correct
if ($content -notmatch '(?m)^name:\s*') {
    $content = $content -replace '^\s*\w+:\s*athletica', 'name: athletica'
    if ($content -notmatch '(?m)^name:\s*') {
        $content = "name: athletica`n$content"
    }
}

# Bump patch and build number
if ($content -match 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3] + 1
    $build = [int]$Matches[4] + 1
    $newVersion = "$major.$minor.$patch+$build"
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersion"
    [System.IO.File]::WriteAllText($PUBSPEC, $content, $encoding)
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

Write-Host "Building prod APK..."
flutter build apk --flavor prod --target lib/main_prod.dart --release
if ($LASTEXITCODE -ne 0) { Write-Error "flutter build failed"; exit 1 }

Write-Host "Distributing to Firebase..."
firebase appdistribution:distribute `
  build/app/outputs/apk/prod/release/app-prod-release.apk `
  --app $FIREBASE_APP_ID `
  --release-notes "Prod build $newVersion" `
  --groups "testers"
if ($LASTEXITCODE -ne 0) { Write-Error "Firebase distribution failed"; exit 1 }

Write-Host "Done. Testers will receive an email with the download link."
