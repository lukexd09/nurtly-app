param(
    [Parameter(Mandatory = $true)]
    [string] $TempDirectory
)

$ErrorActionPreference = "Stop"

function Get-RequiredEnvironmentValue {
    param([string] $Name)

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing required environment value: $Name"
    }

    return $value
}

function Escape-PropertiesValue {
    param([string] $Value)

    return ($Value -replace '\\', '\\\\' -replace ':', '\:' -replace '=', '\=' -replace ' ', '\ ')
}

$keystoreBase64 = Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_BASE64"
$keystorePassword = Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_PASSWORD"
$keyAlias = Get-RequiredEnvironmentValue "ANDROID_KEY_ALIAS"
$keyPassword = Get-RequiredEnvironmentValue "ANDROID_KEY_PASSWORD"

New-Item -ItemType Directory -Force -Path $TempDirectory | Out-Null
$signingRoot = Join-Path $TempDirectory "android-release-signing"
New-Item -ItemType Directory -Force -Path $signingRoot | Out-Null

$keystorePath = Join-Path $signingRoot "upload-keystore.jks"
[IO.File]::WriteAllBytes($keystorePath, [Convert]::FromBase64String($keystoreBase64))

try {
    if ($IsWindows) {
        icacls $keystorePath /inheritance:r /grant:r "$env:USERNAME`:(R,W)" | Out-Null
    }
    else {
        chmod 600 $keystorePath | Out-Null
    }
}
catch {
    Write-Host "INFO restrictive permissions could not be applied on this runner."
}

$keyPropertiesPath = Join-Path (Get-Location) "android/key.properties"
$content = @(
    "storePassword=$(Escape-PropertiesValue $keystorePassword)"
    "keyPassword=$(Escape-PropertiesValue $keyPassword)"
    "keyAlias=$(Escape-PropertiesValue $keyAlias)"
    "storeFile=$(Escape-PropertiesValue $keystorePath)"
) -join "`n"

Set-Content -LiteralPath $keyPropertiesPath -Value $content -NoNewline

try {
    if ($IsWindows) {
        icacls $keyPropertiesPath /inheritance:r /grant:r "$env:USERNAME`:(R,W)" | Out-Null
    }
    else {
        chmod 600 $keyPropertiesPath | Out-Null
    }
}
catch {
    Write-Host "INFO restrictive permissions could not be applied on this runner."
}

Write-Host "Signing keystore written to temporary path: $keystorePath"
Write-Host "Signing properties written to: $keyPropertiesPath"
