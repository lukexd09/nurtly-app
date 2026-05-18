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
    Write-Host "FAILED Flutter/Dart not found." -ForegroundColor Red
    Write-Host "Checked Flutter bin candidates:"
    foreach ($candidate in $flutterBinCandidates) {
        Write-Host " - $candidate"
    }
    Write-Host "Current PATH:"
    Write-Host $env:PATH
    Write-Host "Install Flutter or add Flutter bin to PATH."
    throw "Flutter or Dart is not available."
}

function Invoke-QuietStep {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [scriptblock] $Command
    )

    $output = & $Command 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED $Name" -ForegroundColor Red
        $output | ForEach-Object { Write-Host $_ }
        throw "$Name failed."
    }

    Write-Host "OK $Name" -ForegroundColor Green
}

try {
    Set-Location $appDir

    Invoke-QuietStep "flutter pub get" { flutter pub get }
    Invoke-QuietStep "dart format ." { dart format . }
    Invoke-QuietStep "flutter analyze" { flutter analyze }
    Invoke-QuietStep "flutter test" { flutter test }

    Write-Host "Flutter verification completed successfully." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
