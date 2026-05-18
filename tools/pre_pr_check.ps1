$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

try {
    Set-Location $repoRoot

    & (Join-Path $scriptDir "verify_flutter.ps1")
    & (Join-Path $scriptDir "cleanup_flutter_local.ps1")
    & (Join-Path $scriptDir "check_scope_guard.ps1")
    & (Join-Path $scriptDir "check_flutter_quality.ps1")

    $status = git status --short
    if ($status) {
        Write-Host "Git status:"
        $status | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "Git status clean." -ForegroundColor Green
    }

    Write-Host "Pre-PR check completed successfully." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
