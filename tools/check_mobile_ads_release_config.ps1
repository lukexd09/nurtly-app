param(
    [ValidateSet('debug', 'release')]
    [string] $Mode = 'debug',
    [string] $Profile = '',
    [string] $ApplicationId = '',
    [string] $BannerId = '',
    [string] $WorkflowPath = '',
    [switch] $ValidateRepository
)

$ErrorActionPreference = 'Stop'
$sampleApplicationId = 'ca-app-pub-3940256099942544~3347511713'
$sampleBannerIds = @(
    'ca-app-pub-3940256099942544/6300978111',
    'ca-app-pub-3940256099942544/2934735716'
)

function Fail([string] $message) { throw "Mobile Ads configuration invalid: $message" }
function Assert-AppId([string] $value) {
    if ([string]::IsNullOrWhiteSpace($value)) { Fail 'application ID is required for release.' }
    if ($value -eq $sampleApplicationId) { Fail 'sample application ID is not allowed for release.' }
    if ($value -notmatch '^ca-app-pub-[0-9]{16}~[0-9]{10}$') { Fail 'application ID format is invalid.' }
}
function Assert-BannerId([string] $value, [bool] $required) {
    if ([string]::IsNullOrWhiteSpace($value)) {
        if ($required) { Fail 'production banner ID is required.' }
        return
    }
    if ($value -in $sampleBannerIds) { Fail 'sample banner ID is not allowed for production.' }
    if ($value -notmatch '^ca-app-pub-[0-9]{16}/[0-9]{10}$') { Fail 'banner ID format is invalid.' }
}

if ($ValidateRepository) {
    $manifest = Get-Content -Raw (Join-Path $PSScriptRoot '../app/android/app/src/main/AndroidManifest.xml')
    if ($manifest -notmatch '\$\{nurtlyMobileAdsAndroidAppId\}') { Fail 'manifest placeholder is missing.' }
    $gradle = Get-Content -Raw (Join-Path $PSScriptRoot '../app/android/app/build.gradle')
    if ($gradle -notmatch 'NURTLY_MOBILE_ADS_ANDROID_APP_ID') { Fail 'Gradle release application-ID input is missing.' }
    $workflowFile = if ($WorkflowPath) { $WorkflowPath } else { Join-Path $PSScriptRoot '../.github/workflows/android-release.yml' }
    if (-not (Test-Path -LiteralPath $workflowFile -PathType Leaf)) { Fail 'Android release workflow is missing.' }
    $workflow = Get-Content -Raw -LiteralPath $workflowFile
    function Assert-Workflow([bool] $condition, [string] $message) {
        if (-not $condition) { Fail "release workflow $message" }
    }
    Assert-Workflow ($workflow -match '(?ms)ads_profile:.*?type:\s*choice.*?closed-test-sample-banner.*?production-banner') 'must define both supported ads profiles.'
    Assert-Workflow ($workflow -match '(?ms)- name: Validate Mobile Ads release configuration\s+shell:\s*pwsh') 'validation step must use pwsh.'
    Assert-Workflow ($workflow -match '(?ms)- name: Build app bundle\s+shell:\s*pwsh') 'build step must use pwsh.'
    Assert-Workflow ($workflow -match 'vars\.NURTLY_MOBILE_ADS_ANDROID_APP_ID') 'must source the application ID from the repository variable.'
    Assert-Workflow ($workflow -match '--dart-define=NURTLY_MOBILE_ADS_PROFILE=') 'must pass the profile through dart-define.'
    Assert-Workflow ($workflow -match '--dart-define=NURTLY_MOBILE_ADS_ANDROID_BANNER_ID=') 'must pass the banner ID through dart-define.'
    Assert-Workflow ($workflow -notmatch 'ca-app-pub-3940256099942544') 'must not contain a Google sample identifier.'
    Assert-Workflow ($workflow -notmatch 'ca-app-pub-[0-9]{16}[~/][0-9]{10}') 'must not contain a literal advertising identifier.'
    Assert-Workflow ($workflow -notmatch '(?i)(Write-Host|echo|Out-File).*NURTLY_MOBILE_ADS_ANDROID_(APP|BANNER)_ID') 'must not print full identifier variables.'
    Write-Host 'Repository Mobile Ads release configuration is valid.'
    exit 0
}

if ($Mode -eq 'debug') {
    if ($ApplicationId -and $ApplicationId -ne $sampleApplicationId) { Fail 'debug must use the official sample application ID.' }
    if ($BannerId -and $BannerId -notin $sampleBannerIds) { Fail 'debug must use an official sample banner ID.' }
    Write-Host 'Debug Mobile Ads configuration is valid.'
    exit 0
}

Assert-AppId $ApplicationId
if ($Profile -eq 'closed-test-sample-banner') {
    if ($BannerId -and $BannerId -notin $sampleBannerIds) { Fail 'closed-test-sample-banner requires a sample banner or no banner.' }
} elseif ($Profile -eq 'production-banner') {
    Assert-BannerId $BannerId $true
} else {
    Fail 'release profile is unknown.'
}
Write-Host "Release Mobile Ads configuration is valid for profile '$Profile'."
