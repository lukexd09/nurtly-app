param(
    [Parameter(Mandatory = $true)][string] $RepoRoot,
    [Parameter(Mandatory = $true)][string] $AabPath,
    [Parameter(Mandatory = $true)][string] $OutputDirectory,
    [Parameter(Mandatory = $true)][string] $SourceRef,
    [Parameter(Mandatory = $true)][string] $ResolvedSourceSha,
    [Parameter(Mandatory = $true)][string] $ReleaseNotesFrom,
    [Parameter(Mandatory = $true)][string] $ReleaseNotesRange,
    [Parameter(Mandatory = $true)][string] $RunId,
    [Parameter(Mandatory = $true)][string] $RunAttempt,
    [Parameter(Mandatory = $true)][string] $Repository,
    [Parameter(Mandatory = $true)][string] $WorkflowSha,
    [Parameter(Mandatory = $true)][string] $UtcBuildTimestamp,
    [Parameter(Mandatory = $true)][string] $VersionName,
    [Parameter(Mandatory = $true)][string] $BuildNumber,
    [Parameter(Mandatory = $true)][string] $ExpectedBasename
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $RepoRoot -PathType Container)) {
    throw "Repo root not found: $RepoRoot"
}
if (-not (Test-Path -LiteralPath $AabPath -PathType Leaf)) {
    throw "AAB not found."
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$pubspecPath = Join-Path $RepoRoot "app/pubspec.yaml"
if (-not (Test-Path -LiteralPath $pubspecPath -PathType Leaf)) {
    throw "pubspec.yaml not found."
}

$pubspec = Get-Content -Raw -LiteralPath $pubspecPath
$versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$')
if (-not $versionMatch.Success) { throw "version: entry not found in pubspec.yaml." }
if ($versionMatch.Groups[1].Value -ne $VersionName) { throw "Version mismatch." }
if ($versionMatch.Groups[2].Value -ne $BuildNumber) { throw "Build number mismatch." }

function Write-Utf8NoBom {
    param(
        [string] $Path,
        [string] $Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

$shortSha = $ResolvedSourceSha.Substring(0, 7)
$baseName = "nurtly-android-$VersionName-$BuildNumber-$shortSha"
if ($baseName -ne $ExpectedBasename) { throw "Basename mismatch." }

$targetAab = Join-Path $OutputDirectory "$baseName.aab"
Copy-Item -LiteralPath $AabPath -Destination $targetAab -Force
$checksum = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetAab).Hash.ToLowerInvariant()
Write-Utf8NoBom -Path (Join-Path $OutputDirectory "$baseName.sha256") -Content "$checksum  $baseName.aab`n"

$metadata = [ordered]@{
    schema_version = 1
    repository = $Repository
    workflow_name = "Android Release"
    workflow_run_id = $RunId
    run_attempt = $RunAttempt
    run_url = "https://github.com/$Repository/actions/runs/$RunId"
    workflow_sha = $WorkflowSha
    original_source_ref = $SourceRef
    resolved_source_sha = $ResolvedSourceSha
    short_sha = $shortSha
    version = $VersionName
    build_number = $BuildNumber
    utc_timestamp = $UtcBuildTimestamp
    aab_filename = "$baseName.aab"
    aab_sha256 = $checksum
    automated_validation_result = "PASS"
    manual_qa_status = "NOT_RUN"
    store_delivery_status = "NOT_RUN"
    pending_owner_actions = @(
        "Review the uploaded release artifact.",
        "Run device QA.",
        "Complete any store delivery steps separately."
    )
}

Write-Utf8NoBom -Path (Join-Path $OutputDirectory "$baseName.metadata.json") -Content (($metadata | ConvertTo-Json -Depth 5) + "`n")

$commitSummaries = @()
if ($ReleaseNotesRange -and $ReleaseNotesRange -ne $ResolvedSourceSha) {
    $commitSummaries = @(& git -C $RepoRoot log --no-merges --format="%h %s" $ReleaseNotesRange 2>$null)
}
if (-not $commitSummaries -or $commitSummaries.Count -eq 0) {
    $commitSummaries = @(& git -C $RepoRoot show --no-patch --format="%h %s" $ResolvedSourceSha 2>$null)
}

$releaseNotes = @"
# Android Release Notes

- Source ref: $SourceRef
- Resolved SHA: $ResolvedSourceSha
- Release notes boundary: $ReleaseNotesFrom
- Version: $VersionName
- Build number: $BuildNumber

## Commit summaries

$($commitSummaries -join "`n")
"@
Write-Utf8NoBom -Path (Join-Path $OutputDirectory "$baseName.release-notes.md") -Content ($releaseNotes + "`n")

$evidence = @"
# Android Release Evidence

- Workflow run ID: $RunId
- Run attempt: $RunAttempt
- Workflow SHA: $WorkflowSha
- Source ref: $SourceRef
- Resolved source SHA: $ResolvedSourceSha
- Artifact name: $baseName
- AAB SHA-256: $checksum
- Version/build: $VersionName+$BuildNumber
- Automated validation: PASS
- Manual QA: NOT_RUN
- Store delivery: NOT_RUN
"@
Write-Utf8NoBom -Path (Join-Path $OutputDirectory "$baseName.release-evidence.md") -Content ($evidence + "`n")

Write-Host "Metadata package written to: $OutputDirectory"
Write-Host "Release artifact basename: $baseName"
