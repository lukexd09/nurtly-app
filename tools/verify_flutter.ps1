$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
$appDir = Join-Path $repoRoot "app"

$flutterBinCandidates = @(
    (Join-Path $repoRoot ".fvm\flutter_sdk\bin"),
    "C:\src\flutter\bin"
)

foreach ($candidate in $flutterBinCandidates) {
    if (Test-Path $candidate) {
        $env:PATH = "$candidate;$env:PATH"
    }
}

$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
$dartCommand = Get-Command dart -ErrorAction SilentlyContinue

if (-not $flutterCommand -or -not $dartCommand) {
    Write-Host ""
    Write-Host "Flutter/Dart verification cannot run because Flutter or Dart was not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Checked Flutter bin candidates:"
    foreach ($candidate in $flutterBinCandidates) {
        Write-Host " - $candidate"
    }
    Write-Host ""
    Write-Host "Current PATH:"
    Write-Host $env:PATH
    Write-Host ""
    Write-Host "Expected local setup example:"
    Write-Host " - Flutter SDK: C:\src\flutter"
    Write-Host " - Flutter bin on PATH: C:\src\flutter\bin"
    Write-Host ""
    throw "Flutter or Dart is not available."
}

try {
    Set-Location $appDir

    Write-Host "Running flutter pub get..."
    flutter pub get

    Write-Host "Running dart format..."
    dart format .

    Write-Host "Running flutter analyze..."
    flutter analyze

    Write-Host "Running flutter test..."
    flutter test

    Write-Host ""
    Write-Host "Flutter verification completed successfully." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
