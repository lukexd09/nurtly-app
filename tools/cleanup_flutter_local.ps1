$ErrorActionPreference = "Stop"

$originalLocation = Get-Location

try {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repositoryRoot = Resolve-Path (Join-Path $scriptPath "..")

    Set-Location $repositoryRoot

    $filesToRestore = @(
        "app/ios/Runner/GeneratedPluginRegistrant.h",
        "app/ios/Runner/GeneratedPluginRegistrant.m"
    )

    foreach ($file in $filesToRestore) {
        if (Test-Path $file) {
            git restore -- $file
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
