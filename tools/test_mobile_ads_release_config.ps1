$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot 'check_mobile_ads_release_config.ps1'
$sampleApp = 'ca-app-pub-3940256099942544~3347511713'
$sampleBanner = 'ca-app-pub-3940256099942544/6300978111'
$validApp = 'ca-app-pub-1234567890123456~1234567890'
$validBanner = 'ca-app-pub-1234567890123456/1234567890'

function Expect-Pass([string[]] $arguments) {
    & pwsh -NoLogo -NoProfile -File $script @arguments
    if ($LASTEXITCODE -ne 0) { throw "Expected validation to pass: $($arguments -join ' ')" }
}
function Expect-Fail([string[]] $arguments) {
    $exitCode = 0
    try {
        & pwsh -NoLogo -NoProfile -File $script @arguments *> $null
        $exitCode = $LASTEXITCODE
    }
    catch {
        $exitCode = 1
    }
    if ($exitCode -eq 0) { throw "Expected validation to fail: $($arguments -join ' ')" }
}

Expect-Pass @('-Mode','debug','-ApplicationId',$sampleApp,'-BannerId',$sampleBanner)
Expect-Fail @('-Mode','release','-Profile','production-banner','-BannerId',$validBanner)
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId',$sampleApp,'-BannerId',$validBanner)
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId','malformed','-BannerId',$validBanner)
Expect-Pass @('-Mode','release','-Profile','closed-test-sample-banner','-ApplicationId',$validApp,'-BannerId',$sampleBanner)
Expect-Pass @('-Mode','release','-Profile','closed-test-sample-banner','-ApplicationId',$validApp)
Expect-Pass @('-Mode','release','-Profile','closed-test-sample-banner','-ApplicationId',$validApp,'-BannerId',$validBanner)
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp)
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp,'-BannerId',$sampleBanner)
Expect-Pass @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp,'-BannerId',$validBanner)
Expect-Fail @('-Mode','release','-Profile','unknown','-ApplicationId',$validApp,'-BannerId',$validBanner)
$workflow = Join-Path ([System.IO.Path]::GetTempPath()) 'nurtly-182-invalid-android-release.yml'
$realWorkflow = Join-Path $PSScriptRoot '../.github/workflows/android-release.yml'
function Expect-WorkflowFailure([scriptblock] $mutation) {
    $invalidWorkflow = & $mutation (Get-Content -Raw -LiteralPath $realWorkflow) | Out-String
    [System.IO.File]::WriteAllText($workflow, $invalidWorkflow)
    try { Expect-Fail @('-ValidateRepository','-WorkflowPath',$workflow) }
    finally { Remove-Item -LiteralPath $workflow -Force -ErrorAction SilentlyContinue }
}
Expect-Pass @('-ValidateRepository')
Expect-WorkflowFailure { param($content) $content -replace '(?ms)(- name: Validate Mobile Ads release configuration\s+)shell: pwsh', '$1shell: bash' }
Expect-WorkflowFailure { param($content) $content -replace '(?ms)(- name: Build app bundle\s+)shell: pwsh', '$1shell: bash' }
Expect-WorkflowFailure { param($content) $content -replace 'Out-File -FilePath \$env:GITHUB_STEP_SUMMARY', "Write-Host NURTLY_MOBILE_ADS_ANDROID_APP_ID`n          Out-File -FilePath `$env:GITHUB_STEP_SUMMARY" }
Expect-WorkflowFailure { param($content) $content -replace 'NURTLY_MOBILE_ADS_ANDROID_APP_ID', 'NURTLY_MOBILE_ADS_ANDROID_APP_ID: ca-app-pub-1234567890123456~1234567890' }

function New-SourceFixture {
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ('nurtly-182-source-' + [guid]::NewGuid())
    New-Item -ItemType Directory -Force -Path (Join-Path $root 'app/android/app/src/main'), (Join-Path $root 'app/lib/core/ads') | Out-Null
    Copy-Item (Join-Path $PSScriptRoot '../app/android/app/src/main/AndroidManifest.xml') (Join-Path $root 'app/android/app/src/main/AndroidManifest.xml')
    Copy-Item (Join-Path $PSScriptRoot '../app/android/app/build.gradle') (Join-Path $root 'app/android/app/build.gradle')
    Copy-Item (Join-Path $PSScriptRoot '../app/lib/main.dart') (Join-Path $root 'app/lib/main.dart')
    Copy-Item (Join-Path $PSScriptRoot '../app/lib/core/ads/mobile_ads_runtime_configuration.dart') (Join-Path $root 'app/lib/core/ads/mobile_ads_runtime_configuration.dart')
    return $root
}
function Expect-SourceFailure([scriptblock] $mutation) {
    $root = New-SourceFixture
    try {
        & $mutation $root
        Expect-Fail @('-ValidateRepository','-RepositoryRoot',$root,'-WorkflowPath',$realWorkflow)
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
}
Expect-SourceFailure { param($root) (Get-Content -Raw (Join-Path $root 'app/android/app/src/main/AndroidManifest.xml')) -replace '\$\{nurtlyMobileAdsAndroidAppId\}', $sampleApp | Set-Content (Join-Path $root 'app/android/app/src/main/AndroidManifest.xml') }
Expect-SourceFailure { param($root) (Get-Content -Raw (Join-Path $root 'app/android/app/src/main/AndroidManifest.xml')) -replace '\$\{nurtlyMobileAdsAndroidAppId\}', 'missing' | Set-Content (Join-Path $root 'app/android/app/src/main/AndroidManifest.xml') }
Expect-SourceFailure { param($root) (Get-Content -Raw (Join-Path $root 'app/android/app/build.gradle')) -replace 'NURTLY_MOBILE_ADS_ANDROID_APP_ID', 'REMOVED_APP_ID' | Set-Content (Join-Path $root 'app/android/app/build.gradle') }
Expect-SourceFailure { param($root) (Get-Content -Raw (Join-Path $root 'app/lib/main.dart')) -replace 'NURTLY_MOBILE_ADS_PROFILE', 'REMOVED_PROFILE' | Set-Content (Join-Path $root 'app/lib/main.dart') }
Write-Host 'Mobile Ads release configuration regression tests passed.'
