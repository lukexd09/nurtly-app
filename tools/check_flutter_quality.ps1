$ErrorActionPreference = "Stop"

$originalLocation = Get-Location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

$failPatterns = @(
    "print\(",
    "TODO later",
    "fix later",
    "temporary hack"
)

$warnPatterns = @(
    "GestureDetector\(",
    "debugPrint\("
)

function Get-ChangedDartFiles {
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

    return $files |
        Where-Object { $_ -match "^app/(lib|test)/.*\.dart$" } |
        Sort-Object -Unique
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

try {
    Set-Location $repoRoot
    $changedFiles = @(Get-ChangedDartFiles)
    $failures = @()
    $warnings = @()

    foreach ($file in $changedFiles) {
        $content = Get-Content -Raw -LiteralPath (Join-Path $repoRoot $file)

        foreach ($pattern in $failPatterns) {
            if ($content -match $pattern) {
                $failures += "$pattern found in $file"
            }
        }

        foreach ($pattern in $warnPatterns) {
            if ($content -match $pattern) {
                $warnings += "$pattern found in $file"
            }
        }

        if ($content -match "FutureBuilder\s*<[^>]*>\s*\([^)]*future\s*:\s*[^,\r\n]*(load|get|read|fetch)\s*\(" -or
            $content -match "FutureBuilder\s*\([^)]*future\s*:\s*[^,\r\n]*(load|get|read|fetch)\s*\(") {
            $warnings += "FutureBuilder inline loading pattern found in $file"
        }
    }

    $warnings | Sort-Object -Unique | ForEach-Object {
        Write-Host "WARN $_" -ForegroundColor Yellow
    }

    if ($failures.Count -gt 0) {
        Write-Host "Flutter quality check failed." -ForegroundColor Red
        $failures | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
        throw "Flutter quality check failed."
    }

    Write-Host "Flutter quality check passed." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
}
