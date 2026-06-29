param(
    [Parameter(Mandatory = $true)][string] $AabPath,
    [Parameter(Mandatory = $true)][string] $OutputDirectory,
    [Parameter(Mandatory = $true)][string] $SourceRef,
    [Parameter(Mandatory = $true)][string] $ResolvedSourceSha,
    [Parameter(Mandatory = $true)][string] $ReleaseNotesFrom,
    [Parameter(Mandatory = $true)][string] $RunId,
    [Parameter(Mandatory = $true)][string] $RunAttempt,
    [Parameter(Mandatory = $true)][string] $Repository,
    [Parameter(Mandatory = $true)][string] $WorkflowSha,
    [Parameter(Mandatory = $true)][string] $UtcBuildTimestamp
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $AabPath -PathType Leaf)) {
    throw "AAB not found: $AabPath"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$repoRoot = Split-Path -Parent $PSScriptRoot
$pubspec = Get-Content -Raw -LiteralPath (Join-Path $repoRoot "app/pubspec.yaml")
$versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$')
if (-not $versionMatch.Success) { throw "version: entry not found in app/pubspec.yaml." }

$versionName = $versionMatch.Groups[1].Value
$buildNumber = $versionMatch.Groups[2].Value
$shortSha = $ResolvedSourceSha.Substring(0, 7)
$baseName = "nurtly-android-$versionName-$buildNumber-$shortSha"
$targetAab = Join-Path $OutputDirectory "$baseName.aab"
Copy-Item -LiteralPath $AabPath -Destination $targetAab -Force

$checksum = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetAab).Hash.ToLowerInvariant()
Set-Content -LiteralPath (Join-Path $OutputDirectory "$baseName.sha256") -Value "$checksum  $baseName.aab"

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
    version = $versionName
    build_number = $buildNumber
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

$metadata | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory "$baseName.metadata.json")

$releaseRange = if ($ReleaseNotesFrom -and $ReleaseNotesFrom -ne $ResolvedSourceSha) {
    "$ReleaseNotesFrom..$ResolvedSourceSha"
}
else {
    $ResolvedSourceSha
}
$commitSummaries = @()
$sourceCommitExists = $false
 $previousPreference = $ErrorActionPreference
 $ErrorActionPreference = "SilentlyContinue"
 try {
     & git cat-file -e "$ResolvedSourceSha^{commit}" 2>$null
     if ($LASTEXITCODE -eq 0) {
         $sourceCommitExists = $true
     }
 }
 finally {
     $ErrorActionPreference = $previousPreference
 }
if ($releaseRange -eq $ResolvedSourceSha) {
    if ($sourceCommitExists) {
        $commitSummaries = @(& git show --no-patch --format="%h %s" $ResolvedSourceSha)
    }
}
else {
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $commitSummaries = @(& git log --no-merges --format="%h %s" $releaseRange 2>$null)
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if (($LASTEXITCODE -ne 0 -or $commitSummaries.Count -eq 0) -and $sourceCommitExists) {
        $commitSummaries = @(& git show --no-patch --format="%h %s" $ResolvedSourceSha)
    }
}

$releaseNotes = @"
# Android Release Notes

- Source ref: $SourceRef
- Resolved SHA: $ResolvedSourceSha
- Release notes boundary: $ReleaseNotesFrom
- Version: $versionName
- Build number: $buildNumber

## Commit summaries

$($commitSummaries -join "`n")
"@
Set-Content -LiteralPath (Join-Path $OutputDirectory "$baseName.release-notes.md") -Value $releaseNotes

$evidence = @"
# Android Release Evidence

- Workflow run ID: $RunId
- Run attempt: $RunAttempt
- Workflow SHA: $WorkflowSha
- Source ref: $SourceRef
- Resolved source SHA: $ResolvedSourceSha
- Artifact name: $baseName
- AAB SHA-256: $checksum
- Version/build: $versionName+$buildNumber
- Automated validation: PASS
- Manual QA: NOT_RUN
- Store delivery: NOT_RUN
"@
Set-Content -LiteralPath (Join-Path $OutputDirectory "$baseName.release-evidence.md") -Value $evidence

Write-Host "Metadata package written to: $OutputDirectory"
Write-Host "Release artifact basename: $baseName"
