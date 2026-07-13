param(
    [string] $RepoRoot,
    [string] $ControlRoot,
    [string] $SourceRoot,
    [switch] $AllowPlatformChanges
)

$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
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

$generatedNoisePatterns = @(
    "^\.idea/",
    "^\.gradle/",
    "^app/ios/Flutter/ephemeral/",
    "^app/android/app/src/main/java/"
)

$allowedPlatformFiles = @(
    "^app/android/app/src/main/AndroidManifest\\.xml$",
    "^app/android/app/build\\.gradle$",
    "^app/android/settings\\.gradle$",
    "^app/android/app/src/main/kotlin/com/graylion/nurtly/MainActivity\\.kt$"
)

$approvedSecretTerminologyPaths = @(
    "docs/ci/branch-protection.md",
    "docs/release/android_signing.md",
    "docs/ci/README.md"
)

$approvedSecretTerminologyPhrases = @(
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

$forbiddenPatterns = @(
    "Firebase",
    "Supabase",
    "AdMob",
    "FirebaseAnalytics",
    "firebase_",
    "google_mobile_ads",
    "just_audio",
    "just_audio_background",
    "audio_service",
    "audioplayers",
    "shared_preferences",
    "sqflite",
    "\bhive\b",
    "http:",
    "API_KEY",
    "SECRET",
    "TOKEN=",
    "\.env"
)

function Invoke-GitLines {
    param([string[]] $Arguments)

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $sourceRootPath @Arguments 2>$null
        $script:LastGitExitCode = $LASTEXITCODE
        return $output
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
}

function Get-ChangedFiles {
    $files = @()
    $files += Invoke-GitLines @("diff", "--name-only")
    $files += Invoke-GitLines @("diff", "--cached", "--name-only")
    $files += Invoke-GitLines @("ls-files", "--others", "--exclude-standard")

    $base = $null
    foreach ($candidate in @("origin/main", "main")) {
        Invoke-GitLines @("rev-parse", "--verify", $candidate) | Out-Null
        if ($script:LastGitExitCode -eq 0) {
            $base = & git -C $sourceRootPath merge-base HEAD $candidate
            if ($LASTEXITCODE -ne 0) {
                $base = $null
            }
            break
        }
    }

    if ($base) {
        $files += Invoke-GitLines @("diff", "--name-only", "$base...HEAD")
    }

    return $files | Where-Object { $_ } | Sort-Object -Unique
}

function Test-IsTextFile {
    param([string] $Path)

    $fullPath = Join-Path $sourceRootPath $Path
    if (-not (Test-Path $fullPath -PathType Leaf)) {
        return $false
    }

    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    $sampleLength = [Math]::Min($bytes.Length, 4096)
    for ($i = 0; $i -lt $sampleLength; $i++) {
        if ($bytes[$i] -eq 0) {
            return $false
        }
    }

    return $true
}

function Test-ShouldScanForbiddenPatterns {
    param([string] $Path)

    $normalized = $Path -replace "\\", "/"
    return $normalized -ne "AGENTS.md" -and
        $normalized -ne "tools/check_scope_guard.ps1"
}

function Test-IsAllowedJustAudioUsage {
    param(
        [string] $Path,
        [string] $Pattern
    )

    if ($Pattern -ne "just_audio") {
        return $false
    }

    $normalized = $Path -replace "\\", "/"
    return $normalized -in @(
        "app/pubspec.yaml",
        "app/pubspec.lock",
        "app/lib/features/sounds/sounds_screen.dart",
        "app/lib/features/sounds/widgets/suggested_sound_mini_player.dart",
        "app/lib/features/sounds/audio/looping_sound_loader.dart"
    )
}

function Test-IsAllowedSharedPreferencesUsage {
    param(
        [string] $Path,
        [string] $Pattern
    )

    if ($Pattern -ne "shared_preferences") {
        return $false
    }

    $normalized = $Path -replace "\\", "/"
    return $normalized -in @(
        "app/pubspec.yaml",
        "app/pubspec.lock",
        "app/lib/core/localization/language_preference_store.dart",
        "app/lib/core/monetization/reviewer_access_store.dart",
        "app/test/core/monetization/reviewer_access_store_test.dart",
        "app/test/core/localization/language_preference_store_test.dart",
        "app/lib/features/journal/journal_store.dart",
        "app/test/features/journal/journal_store_test.dart"
    )
}

function Test-IsAllowedGoogleMobileAdsUsage {
    param(
        [string] $Path,
        [string] $Pattern
    )

    if ($Pattern -ne "google_mobile_ads") {
        return $false
    }

    $normalized = $Path -replace "\\", "/"
    return $normalized -in @(
        "app/pubspec.yaml",
        "app/pubspec.lock",
        "app/lib/core/ads/ad_widget_factory.dart",
        "app/lib/core/ads/consent_flow_controller.dart",
        "app/lib/main.dart"
    )
}

function Test-ForbiddenPatternMatch {
    param(
        [string] $Content,
        [string] $Pattern
    )

    if ($Pattern -ne "http:") {
        return $Content -match $Pattern
    }

    $lines = $Content -split "`r?`n"
    foreach ($line in $lines) {
        if (($line -match $Pattern) -and
            ($line -notmatch 'xmlns:android="http://schemas\.android\.com/apk/res/android"')) {
            return $true
        }
    }

    return $false
}

function Remove-ApprovedSecretTerminology {
    param([string] $Line)

    $sanitized = $Line
    foreach ($phrase in $approvedSecretTerminologyPhrases) {
        $sanitized = [regex]::Replace(
            $sanitized,
            [regex]::Escape($phrase),
            '',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }

    return $sanitized
}

function Test-LineContainsApprovedSecretTerminology {
    param([string] $Line)

    foreach ($phrase in $approvedSecretTerminologyPhrases) {
        if ($Line -match [regex]::Escape($phrase)) {
            return $true
        }
    }

    return $false
}

function Get-LineRefs {
    param([string] $Path)
    $content = Get-Content -LiteralPath $Path
    for ($i = 0; $i -lt $content.Count; $i++) {
        [pscustomobject]@{ LineNumber = $i + 1; Line = $content[$i] }
    }
}

function Test-AndroidApplicationId {
    param(
        [string] $BuildFilePath,
        [string] $ExpectedApplicationId
    )

    $content = Get-Content -Raw -LiteralPath $BuildFilePath
    if ($content -notmatch "applicationId\s*=\s*`"$([regex]::Escape($ExpectedApplicationId))`"") {
        Add-Failure "Production Android applicationId must be exactly $ExpectedApplicationId in $BuildFilePath"
    }
}

function Test-IsAllowedPlatformFile {
    param([string] $Path)

    $normalized = $Path -replace "\\", "/"
    return $normalized -in @(
        "app/android/app/src/main/AndroidManifest.xml",
        "app/android/app/src/main/res/xml/backup_rules.xml",
        "app/android/app/src/main/res/xml/data_extraction_rules.xml",
        "app/android/app/build.gradle",
        "app/android/settings.gradle",
        "app/android/app/src/main/kotlin/com/graylion/nurtly/MainActivity.kt"
    )
}

function Test-AndroidMainActivityIdentity {
    param(
        [string] $RepoRootPath,
        [string] $ExpectedMainActivityPath,
        [string] $ObsoleteMainActivityPath,
        [string] $ExpectedPackageLine
    )

    $expectedFullPath = Join-Path $RepoRootPath $ExpectedMainActivityPath
    $obsoleteFullPath = Join-Path $RepoRootPath $ObsoleteMainActivityPath

    if (-not (Test-Path $expectedFullPath -PathType Leaf)) {
        Add-Failure "Expected Android MainActivity file is missing: $ExpectedMainActivityPath"
    }

    if (Test-Path $obsoleteFullPath -PathType Leaf) {
        Add-Failure "Obsolete Android MainActivity file still exists: $ObsoleteMainActivityPath"
    }

    if (Test-Path $expectedFullPath -PathType Leaf) {
        $firstLine = Get-Content -LiteralPath $expectedFullPath -TotalCount 1
        if ($firstLine -ne $ExpectedPackageLine) {
            Add-Failure "Android MainActivity package declaration must be exactly '$ExpectedPackageLine' in $ExpectedMainActivityPath"
        }
    }
}

function Add-Failure {
    param([string] $Message)
    $script:failures.Add($Message) | Out-Null
}

try {
    Set-Location $sourceRootPath

    $releaseWorkflow = Join-Path $controlRootPath ".github/workflows/android-release.yml"
    $signingHelper = Join-Path $controlRootPath "tools/prepare_android_signing.ps1"
    $docsToCheck = @(
        (Join-Path $controlRootPath "docs/ci/README.md"),
        (Join-Path $controlRootPath "docs/ci/branch-protection.md"),
        (Join-Path $controlRootPath "docs/release/android_signing.md"),
        (Join-Path $controlRootPath "docs/release/android_release_workflow.md")
    )
    $androidBuildFile = Join-Path $controlRootPath "app/android/app/build.gradle"

    if (-not (Test-Path $releaseWorkflow)) { throw "Missing release workflow." }
    if (-not (Test-Path $signingHelper)) { throw "Missing signing helper." }

    $changedFiles = @(Get-ChangedFiles)
    $script:failures = New-Object 'System.Collections.Generic.List[string]'

    foreach ($file in $changedFiles) {
        $normalized = $file -replace "\\", "/"
        $isDedicatedSecretFile =
            $normalized -eq ".github/workflows/android-release.yml" -or
            $normalized -in $approvedSecretTerminologyPaths

        foreach ($pattern in $generatedNoisePatterns) {
            if ($normalized -match $pattern) {
                Add-Failure "Generated/local noise changed: $normalized"
            }
        }

        if (-not $AllowPlatformChanges) {
            $isPlatformFile = $normalized -match '^app/android/' -or $normalized -match '^app/ios/'
            $isAllowedPlatformFile = Test-IsAllowedPlatformFile $normalized

            if ($isPlatformFile -and -not $isAllowedPlatformFile) {
                Add-Failure "Platform file changed without -AllowPlatformChanges: $normalized"
            }
        }

        if ((Test-ShouldScanForbiddenPatterns $normalized) -and (Test-IsTextFile $normalized)) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $sourceRootPath $normalized)
            foreach ($pattern in $forbiddenPatterns) {
                if (Test-IsAllowedJustAudioUsage $normalized $pattern) { continue }
                if (Test-IsAllowedSharedPreferencesUsage $normalized $pattern) { continue }
                if (Test-IsAllowedGoogleMobileAdsUsage $normalized $pattern) { continue }
                if ($pattern -eq "SECRET" -and $isDedicatedSecretFile) { continue }
                if ($pattern -eq "SECRET") {
                    $lines = $content -split "`r?`n"
                    foreach ($line in $lines) {
                        if ($line -notmatch '(?i)SECRET') { continue }
                        $sanitizedLine = Remove-ApprovedSecretTerminology $line
                        if ($sanitizedLine -match '(?i)SECRET') {
                            Add-Failure "Forbidden SECRET wording on line content in ${normalized}: $line"
                        }
                    }
                    continue
                }

                if (Test-ForbiddenPatternMatch $content $pattern) {
                    Add-Failure "Forbidden pattern '$pattern' found in $normalized"
                }
            }
        }
    }

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
            foreach ($name in @('ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD', 'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD')) {
                if ($line -match "^\s*$name\s*[:=]") {
                    Add-Failure "Protected name assignment on line $($entry.LineNumber) in $doc"
                }
            }
            if ($line -match '\$\{\{\s*secrets\.[A-Z0-9_]+\s*\}\}') {
                Add-Failure "Workflow secret reference in documentation on line $($entry.LineNumber) in $doc"
            }
            if ($line -match '(?i)SECRET') {
                $sanitizedLine = Remove-ApprovedSecretTerminology $line
                if ($sanitizedLine -match '(?i)SECRET') {
                    Add-Failure "Forbidden SECRET wording on line $($entry.LineNumber) in $doc"
                }
            }
        }
    }

    Test-AndroidApplicationId -BuildFilePath $androidBuildFile -ExpectedApplicationId "com.graylion.nurtly"
    Test-AndroidMainActivityIdentity `
        -RepoRootPath $sourceRootPath `
        -ExpectedMainActivityPath "app/android/app/src/main/kotlin/com/graylion/nurtly/MainActivity.kt" `
        -ObsoleteMainActivityPath "app/android/app/src/main/kotlin/com/nurtly/app/MainActivity.kt" `
        -ExpectedPackageLine "package com.graylion.nurtly"

    if (-not $AllowPlatformChanges) {
        $platformChanges = $changedFiles | Where-Object {
            $normalized = $_ -replace "\\", "/"
            $normalized -match '^app/(android|ios)/' -and -not (Test-IsAllowedPlatformFile $normalized)
        }
        foreach ($platformChange in $platformChanges) {
            Add-Failure "Platform file changed without -AllowPlatformChanges: $($platformChange -replace '\\','/')"
        }
    }

    if ($script:failures.Count -gt 0) {
        Write-Host "Scope guard failed." -ForegroundColor Red
        $script:failures | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
        throw "Scope guard failed."
    }

    Write-Host "Scope guard passed." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
