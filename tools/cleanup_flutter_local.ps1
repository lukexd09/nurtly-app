param(
    [string] $RepoRoot
)

$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Join-Path $scriptDir ".."
}

try {
    $repositoryRoot = (Resolve-Path $RepoRoot).Path

    Set-Location $repositoryRoot

    $filesToRestore = @(
        "app/ios/Runner/GeneratedPluginRegistrant.h",
        "app/ios/Runner/GeneratedPluginRegistrant.m"
    )

    foreach ($file in $filesToRestore) {
        if (Test-Path $file) {
            $null = & git ls-files --error-unmatch -- $file 1>$null 2>$null
            if ($LASTEXITCODE -eq 0) {
                try {
                    & git -C $repositoryRoot restore -- $file 1>$null 2>$null
                }
                catch {
                }
            }
        }
    }

    $pathsToRemove = @(
        "app/android/app/src/main/java",
        "app/ios/Flutter/ephemeral"
    )

    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
    }
}
finally {
    Set-Location $originalLocation
}
