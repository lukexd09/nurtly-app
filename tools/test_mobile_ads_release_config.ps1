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
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp)
Expect-Fail @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp,'-BannerId',$sampleBanner)
Expect-Pass @('-Mode','release','-Profile','production-banner','-ApplicationId',$validApp,'-BannerId',$validBanner)
Expect-Fail @('-Mode','release','-Profile','unknown','-ApplicationId',$validApp,'-BannerId',$validBanner)
$workflow = Join-Path ([System.IO.Path]::GetTempPath()) 'nurtly-182-invalid-android-release.yml'
$realWorkflow = Join-Path $PSScriptRoot '../.github/workflows/android-release.yml'
$invalidWorkflow = (Get-Content -Raw -LiteralPath $realWorkflow) -replace '(?ms)(- name: Validate Mobile Ads release configuration\s+)shell: pwsh', '$1shell: bash'
[System.IO.File]::WriteAllText($workflow, $invalidWorkflow)
try {
    Expect-Fail @('-ValidateRepository','-WorkflowPath',$workflow)
}
finally {
    Remove-Item -LiteralPath $workflow -Force -ErrorAction SilentlyContinue
}
Write-Host 'Mobile Ads release configuration regression tests passed.'
