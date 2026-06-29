param(
    [switch] $AllowPlatformChanges
)

$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

$generatedNoisePatterns = @(
    "^\.idea/",
    "^\.gradle/",
    "^app/ios/Flutter/ephemeral/",
    "^app/android/app/src/main/java/"
)

$platformPatterns = @(
    "^app/android/",
    "^app/ios/"
)

$allowedPlatformFiles = @(
    "^app/android/app/src/main/AndroidManifest\\.xml$"
)

$approvedSecretTerminologyPaths = @(
    "docs/ci/branch-protection.md",
    "docs/release/android_signing.md",
    "docs/ci/README.md",
    ".github/workflows/android-release.yml"
)

$approvedSecretTerminologyPhrases = @(
    'GitHub Environment secret',
    'GitHub Environment secrets',
    'Environment secret',
    'Environment secrets',
    'environment secret name',
    'environment secret names',
    'environment secret value',
    'environment secret values'
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
    "hive",
    "http:",
    "API_KEY",
    "ANDROID_KEYSTORE_BASE64",
    "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS",
    "ANDROID_KEY_PASSWORD",
    "SECRET",
    "TOKEN=",
    "\.env"
)

function Get-ChangedFiles {
    $files = @()
    $files += Invoke-GitLines @("diff", "--name-only")
    $files += Invoke-GitLines @("diff", "--cached", "--name-only")
    $files += Invoke-GitLines @("ls-files", "--others", "--exclude-standard")

    $base = $null
    foreach ($candidate in @("origin/main", "main")) {
        Invoke-GitLines @("rev-parse", "--verify", $candidate) | Out-Null
        if ($script:LastGitExitCode -eq 0) {
            $base = git merge-base HEAD $candidate
            break
        }
    }

    if ($base) {
        $files += Invoke-GitLines @("diff", "--name-only", "$base...HEAD")
    }

    return $files | Where-Object { $_ } | Sort-Object -Unique
}

function Invoke-GitLines {
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

function Test-IsTextFile {
    param([string] $Path)

    $fullPath = Join-Path $repoRoot $Path
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

try {
    Set-Location $repoRoot
    $changedFiles = @(Get-ChangedFiles)
    $failures = @()

    foreach ($file in $changedFiles) {
        $normalized = $file -replace "\\", "/"

        foreach ($pattern in $generatedNoisePatterns) {
            if ($normalized -match $pattern) {
                $failures += "Generated/local noise changed: $file"
            }
        }

        if (-not $AllowPlatformChanges) {
            $isPlatformFile = $normalized -match '^app/android/' -or $normalized -match '^app/ios/'
            $isAllowedPlatformFile =
                $normalized -eq 'app/android/app/src/main/AndroidManifest.xml'

            if ($isPlatformFile -and -not $isAllowedPlatformFile) {
                $failures += "Platform file changed without -AllowPlatformChanges: $file"
            }
        }

        if ((Test-ShouldScanForbiddenPatterns $normalized) -and
            (Test-IsTextFile $normalized)) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $repoRoot $normalized)
            foreach ($pattern in $forbiddenPatterns) {
                if ($normalized -eq ".github/workflows/android-release.yml" -and
                    $pattern -in @("ANDROID_KEYSTORE_BASE64","ANDROID_KEYSTORE_PASSWORD","ANDROID_KEY_ALIAS","ANDROID_KEY_PASSWORD")) {
                    if ($content -notmatch [regex]::Escape("secrets.$pattern")) {
                        $failures += "Expected release workflow to reference secrets.$pattern"
                    }
                    continue
                }
                if ($normalized -in @("docs/release/android_release_workflow.md","docs/release/android_signing.md") -and
                    $pattern -in @("ANDROID_KEYSTORE_BASE64","ANDROID_KEYSTORE_PASSWORD","ANDROID_KEY_ALIAS","ANDROID_KEY_PASSWORD")) {
                    continue
                }
                if ($normalized -eq "tools/prepare_android_signing.ps1" -and
                    $pattern -in @("ANDROID_KEYSTORE_BASE64","ANDROID_KEYSTORE_PASSWORD","ANDROID_KEY_ALIAS","ANDROID_KEY_PASSWORD")) {
                    continue
                }
                if (Test-IsAllowedJustAudioUsage $normalized $pattern) {
                    continue
                }
                if (Test-IsAllowedSharedPreferencesUsage $normalized $pattern) {
                    continue
                }
                if (Test-IsAllowedGoogleMobileAdsUsage $normalized $pattern) {
                    continue
                }
                if ($pattern -eq "SECRET") {
                    if ($normalized -in @("docs/release/android_release_workflow.md","docs/release/android_signing.md")) {
                        continue
                    }
                    $lines = $content -split "`r?`n"
                    foreach ($line in $lines) {
                        if ($line -notmatch '(?i)SECRET') {
                            continue
                        }

                        if ($normalized -eq ".github/workflows/android-release.yml" -and
                            $line -match 'secrets\.ANDROID_KEY(STORE_BASE64|STORE_PASSWORD|_ALIAS|_PASSWORD)') {
                            continue
                        }

                        if ($normalized -in @("docs/release/android_release_workflow.md","docs/release/android_signing.md") -and
                            $line -match 'ANDROID_KEY(STORE_BASE64|STORE_PASSWORD|_ALIAS|_PASSWORD)') {
                            continue
                        }

                        if ($normalized -eq "tools/prepare_android_signing.ps1" -and
                            $line -match 'ANDROID_KEY(STORE_BASE64|STORE_PASSWORD|_ALIAS|_PASSWORD)') {
                            continue
                        }

                        if ($normalized -in $approvedSecretTerminologyPaths -and
                            $line -match '(?i)\b[A-Z0-9_]*SECRET[A-Z0-9_]*\s*[:=]') {
                            $failures += "Forbidden pattern '$pattern' found in $file"
                            continue
                        }

                        $sanitizedLine = $line
                        if ($normalized -in $approvedSecretTerminologyPaths -and
                            (Test-LineContainsApprovedSecretTerminology $line)) {
                            $sanitizedLine = Remove-ApprovedSecretTerminology $line
                        }

                        if ($sanitizedLine -match '(?i)SECRET') {
                            if ($sanitizedLine -match '(?i)GitHub') {
                                continue
                            }
                            $failures += "Forbidden pattern '$pattern' found in $file"
                        }
                    }
                    continue
                }

                if ($pattern -eq "hive") {
                    if ($normalized -in @(".github/workflows/android-release.yml","docs/release/android_release_workflow.md","docs/release/closed_testing_release_candidate_evidence.md")) {
                        continue
                    }
                    $lines = $content -split "`r?`n"
                    foreach ($line in $lines) {
                        if ($line -match $pattern -and $line -notmatch '(?i)GitHub') {
                            $failures += "Forbidden pattern '$pattern' found in $file"
                        }
                    }
                    continue
                }

                if (Test-ForbiddenPatternMatch $content $pattern) {
                    $failures += "Forbidden pattern '$pattern' found in $file"
                }
            }
        }
    }

    if ($failures.Count -gt 0) {
        Write-Host "Scope guard failed." -ForegroundColor Red
        $failures | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
        throw "Scope guard failed."
    }

    Write-Host "Scope guard passed." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
