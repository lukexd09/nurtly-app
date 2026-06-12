param(
    [switch] $AllowDirty
)

$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

function Add-Issue {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    $script:Issues += $Message
}

function Invoke-Git {
    param([string[]] $Arguments)

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @Arguments 2>$null
        $script:LastGitExitCode = $LASTEXITCODE
        return $output
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
}

function Test-TrackedOrStagedPattern {
    param([string[]] $Patterns)

    $tracked = @()
    $tracked += Invoke-Git -Arguments (@("ls-files", "--") + $Patterns)
    $staged = @()
    $staged += Invoke-Git -Arguments (@("diff", "--cached", "--name-only", "--") + $Patterns)

    return @($tracked + $staged) | Where-Object { $_ } | Sort-Object -Unique
}

function Test-PathExistsSafe {
    param([string] $Path)

    return Test-Path -LiteralPath $Path -PathType Leaf
}

try {
    Set-Location $repoRoot
    $script:Issues = @()

    Write-Host "Release preflight: repository root is $repoRoot"
    Write-Host "Release preflight: checking local signing files and artifact safety only."

    $keyPropertiesPath = Join-Path $repoRoot "app\android\key.properties"
    $uploadKeystorePath = Join-Path $repoRoot "app\android\upload-keystore.jks"
    $localKeystorePatterns = @("*.jks", "*.keystore", "*.aab", "*.apk", "key.properties")

    if (-not (Test-PathExistsSafe $keyPropertiesPath)) {
        Add-Issue "Missing required local signing file: app/android/key.properties"
    }
    else {
        $keyProperties = Get-Content -Raw -LiteralPath $keyPropertiesPath
        $storeFileMatch = [regex]::Match($keyProperties, '(?m)^storeFile=(.+)$')
        if (-not $storeFileMatch.Success) {
            Add-Issue "app/android/key.properties is missing a storeFile entry."
        }
        else {
            $storeFileValue = $storeFileMatch.Groups[1].Value.Trim()
            $resolvedStoreFile = Join-Path (Split-Path -Parent $keyPropertiesPath) $storeFileValue
            if (-not (Test-Path -LiteralPath $resolvedStoreFile -PathType Leaf)) {
                Add-Issue "The keystore referenced by app/android/key.properties does not exist."
            }
        }
    }

    if (-not (Test-PathExistsSafe $uploadKeystorePath)) {
        Write-Host "INFO app/android/upload-keystore.jks is not present."
    }
    else {
        Write-Host "OK app/android/upload-keystore.jks exists."
    }

    $trackedOrStagedArtifacts = @(Test-TrackedOrStagedPattern -Patterns $localKeystorePatterns)
    if ($trackedOrStagedArtifacts.Count -gt 0) {
        foreach ($item in $trackedOrStagedArtifacts) {
            Add-Issue "Release artifact or signing file is tracked/staged in git: $item"
        }
    }

    $statusMatches = Invoke-Git @("status", "--short")
    foreach ($line in $statusMatches) {
        if ($line -match '(\.aab|\.apk|\.jks|\.keystore|key\.properties)$') {
            Add-Issue "Release artifact or signing file appears in git status: $line"
        }
    }

    $diffCheckOutput = & git diff --check 2>&1
    if ($LASTEXITCODE -ne 0) {
        Add-Issue "git diff --check failed."
        $diffCheckOutput | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "OK git diff --check"
    }

    if ($Issues.Count -gt 0) {
        Write-Host "FAILED release preflight." -ForegroundColor Red
        $Issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
        throw "Release preflight failed."
    }

    Write-Host "OK release signing files and artifact safety." -ForegroundColor Green
    Write-Host "Release preflight completed successfully." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
