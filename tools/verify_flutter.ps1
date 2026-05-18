$ErrorActionPreference = "Stop"

$originalLocation = Get-Location

try {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repositoryRoot = Resolve-Path (Join-Path $scriptPath "..")
    $appPath = Join-Path $repositoryRoot "app"

    Set-Location $repositoryRoot
    Set-Location $appPath

    dart format .
    flutter analyze
    flutter test
}
finally {
    Set-Location $originalLocation
}
