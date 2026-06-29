param(
    [string] $RepoRoot,
    [string] $ControlRoot,
    [string] $SourceRoot,
    [switch] $AllowPlatformChanges
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$defaultRepoRoot = Join-Path $scriptDir ".."

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = $defaultRepoRoot
}

$repoRootPath = (Resolve-Path $RepoRoot).Path

if ([string]::IsNullOrWhiteSpace($ControlRoot)) {
    $ControlRoot = $repoRootPath
}

if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $SourceRoot = $repoRootPath
}

$controlRootPath = (Resolve-Path $ControlRoot).Path
$sourceRootPath = (Resolve-Path $SourceRoot).Path
$releaseWorkflow = Join-Path $controlRootPath ".github/workflows/android-release.yml"
$signingHelper = Join-Path $controlRootPath "tools/prepare_android_signing.ps1"
$docsToCheck = @(
    (Join-Path $controlRootPath "docs/ci/branch-protection.md"),
    (Join-Path $controlRootPath "docs/release/android_signing.md"),
    (Join-Path $controlRootPath "docs/release/android_release_workflow.md")
)
$failures = New-Object System.Collections.Generic.List[string]

$approvedTerminologyPhrases = @(
    'GitHub Actions secret',
    'GitHub Actions secrets',
    'repository secret',
    'repository secrets',
    'repository-level Actions secret',
    'repository-level Actions secrets',
    'Secrets and variables',
    'secret name',
    'secret names',
    'secret value',
    'secret values'
)

$protectedNames = @(
    'ANDROID_KEYSTORE_BASE64',
    'ANDROID_KEYSTORE_PASSWORD',
    'ANDROID_KEY_ALIAS',
    'ANDROID_KEY_PASSWORD'
)

function Test-ApprovedSecretTerminologyLine {
    param([string] $Line)
    $sanitized = $Line
    foreach ($phrase in $approvedTerminologyPhrases) {
        $sanitized = [regex]::Replace($sanitized, [regex]::Escape($phrase), '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    return -not ($sanitized -match '(?i)SECRET')
}

function Get-LineRefs {
    param([string] $Path)
    $content = Get-Content -LiteralPath $Path
    for ($i = 0; $i -lt $content.Count; $i++) {
        [pscustomobject]@{ LineNumber = $i + 1; Line = $content[$i] }
    }
}

function Add-Failure {
    param([string] $Message)
    $script:failures.Add($Message) | Out-Null
}

if (-not (Test-Path $releaseWorkflow)) { throw "Missing release workflow." }
if (-not (Test-Path $signingHelper)) { throw "Missing signing helper." }

$releaseAllowed = @{
    'ANDROID_KEYSTORE_BASE64' = 'secrets.ANDROID_KEYSTORE_BASE64'
    'ANDROID_KEYSTORE_PASSWORD' = 'secrets.ANDROID_KEYSTORE_PASSWORD'
    'ANDROID_KEY_ALIAS' = 'secrets.ANDROID_KEY_ALIAS'
    'ANDROID_KEY_PASSWORD' = 'secrets.ANDROID_KEY_PASSWORD'
}

$workflowCounts = @{}
foreach ($key in $releaseAllowed.Keys) { $workflowCounts[$key] = 0 }
foreach ($entry in Get-LineRefs $releaseWorkflow) {
    foreach ($key in $releaseAllowed.Keys) {
        if ($entry.Line -match [regex]::Escape($key)) {
            if ($entry.Line -notmatch "^\s*$key\s*:\s*\$\{\{\s*$($releaseAllowed[$key])\s*\}\}\s*$") {
                Add-Failure "Forbidden release workflow reference on line $($entry.LineNumber): $($entry.Line)"
            }
            $workflowCounts[$key]++
        }
    }
    if ($entry.Line -match '^\s*[A-Z0-9_]*SECRET[A-Z0-9_]*\s*[:=]' -and $entry.Line -notmatch '^\s*(ANDROID_KEYSTORE_BASE64|ANDROID_KEYSTORE_PASSWORD|ANDROID_KEY_ALIAS|ANDROID_KEY_PASSWORD)\s*:\s*\$\{\{\s*secrets\.(ANDROID_KEYSTORE_BASE64|ANDROID_KEYSTORE_PASSWORD|ANDROID_KEY_ALIAS|ANDROID_KEY_PASSWORD)\s*\}\}\s*$') {
        Add-Failure "Forbidden secret assignment in release workflow on line $($entry.LineNumber): $($entry.Line)"
    }
    if ($entry.Line -match '\$\{\{\s*secrets\.[A-Z0-9_]+\s*\}\}' -and $entry.Line -notmatch 'secrets\.ANDROID_KEY(STORE_BASE64|STORE_PASSWORD|_ALIAS|_PASSWORD)') {
        Add-Failure "Unexpected secrets reference in release workflow on line $($entry.LineNumber): $($entry.Line)"
    }
}
foreach ($key in $releaseAllowed.Keys) {
    if ($workflowCounts[$key] -ne 1) {
        Add-Failure "Expected exactly one workflow mapping for $key but found $($workflowCounts[$key])."
    }
}

$helperAllowed = @{
    'ANDROID_KEYSTORE_BASE64' = 'Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_BASE64"'
    'ANDROID_KEYSTORE_PASSWORD' = 'Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_PASSWORD"'
    'ANDROID_KEY_ALIAS' = 'Get-RequiredEnvironmentValue "ANDROID_KEY_ALIAS"'
    'ANDROID_KEY_PASSWORD' = 'Get-RequiredEnvironmentValue "ANDROID_KEY_PASSWORD"'
}

$helperCounts = @{}
foreach ($key in $helperAllowed.Keys) { $helperCounts[$key] = 0 }
foreach ($entry in Get-LineRefs $signingHelper) {
    foreach ($key in $helperAllowed.Keys) {
        if ($entry.Line -match [regex]::Escape($key)) {
            if ($entry.Line -notmatch $helperAllowed[$key]) {
                Add-Failure "Forbidden helper reference on line $($entry.LineNumber): $($entry.Line)"
            }
            $helperCounts[$key]++
        }
    }
    if ($entry.Line -match '\$\{\{\s*secrets\.[A-Z0-9_]+\s*\}\}') {
        Add-Failure "Unexpected workflow secret reference in signing helper on line $($entry.LineNumber): $($entry.Line)"
    }
}
foreach ($key in $helperAllowed.Keys) {
    if ($helperCounts[$key] -ne 1) {
        Add-Failure "Expected exactly one helper occurrence for $key but found $($helperCounts[$key])."
    }
}

foreach ($doc in $docsToCheck) {
    foreach ($entry in Get-LineRefs $doc) {
        $line = $entry.Line
        if ($line -match '^\s*[A-Z0-9_]*SECRET[A-Z0-9_]*\s*[:=]') {
            Add-Failure "Literal secret assignment on line $($entry.LineNumber) in $doc"
        }
        foreach ($name in $protectedNames) {
            if ($line -match "^\s*$name\s*[:=]" -and $doc -notmatch 'android_release_workflow\.md$') {
                Add-Failure "Protected name assignment on line $($entry.LineNumber) in $doc"
            }
        }
        if ($line -match '\$\{\{\s*secrets\.[A-Z0-9_]+\s*\}\}') {
            Add-Failure "Workflow secret reference in documentation on line $($entry.LineNumber) in $doc"
        }
        if ($line -match '(?i)SECRET' -and $line -match '^\s*[^`#-][^:=]*[:=]' -and -not (Test-ApprovedSecretTerminologyLine $line)) {
            Add-Failure "Forbidden SECRET wording on line $($entry.LineNumber) in $doc"
        }
    }
}

if (-not $AllowPlatformChanges) {
    $changedFiles = @()
    foreach ($command in @(
        @('diff', '--name-only'),
        @('diff', '--cached', '--name-only'),
        @('ls-files', '--others', '--exclude-standard')
    )) {
        $changedFiles += & git -C $repoRootPath @command
    }
    $platformChanges = $changedFiles | Where-Object { $_ -match '^app/(android|ios)/' }
    foreach ($platformChange in $platformChanges) {
        Add-Failure "Platform file changed without -AllowPlatformChanges: $($platformChange -replace '\\','/')"
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Scope guard failed." -ForegroundColor Red
    $failures | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
    throw "Scope guard failed."
}

Write-Host "Scope guard passed." -ForegroundColor Green
