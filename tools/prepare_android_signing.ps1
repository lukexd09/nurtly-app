param(
    [Parameter(Mandatory = $true)]
    [string] $RepoRoot,
    [Parameter(Mandatory = $true)]
    [string] $TempDirectory,
    [string] $KeyPropertiesPath
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

function Escape-JavaPropertiesValue {
    param([string] $Value)
    $builder = New-Object System.Text.StringBuilder
    foreach ($char in $Value.ToCharArray()) {
        switch ([int][char]$char) {
            0x5C { [void]$builder.Append('\\') }
            0x20 { [void]$builder.Append('\ ') }
            0x09 { [void]$builder.Append('\t') }
            0x0A { [void]$builder.Append('\n') }
            0x0D { [void]$builder.Append('\r') }
            0x0C { [void]$builder.Append('\f') }
            0x23 { [void]$builder.Append('\#') }
            0x21 { [void]$builder.Append('\!') }
            0x3A { [void]$builder.Append('\:') }
            0x3D { [void]$builder.Append('\=') }
            default {
                if ([int][char]$char -lt 0x20 -or [int][char]$char -gt 0x7E) {
                    [void]$builder.Append(('\u{0:X4}' -f [int][char]$char))
                }
                else {
                    [void]$builder.Append($char)
                }
            }
        }
    }
    return $builder.ToString()
}

function Write-PropertiesFile {
    param(
        [hashtable] $Entries,
        [string] $Path
    )
    $lines = foreach ($key in $Entries.Keys) {
        "{0}={1}" -f $key, (Escape-JavaPropertiesValue $Entries[$key])
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($lines -join "`n") + "`n", $utf8NoBom)
}

function Grant-RestrictiveAccess {
    param([string] $Path)
    try {
        if ($IsWindows) {
            icacls $Path /inheritance:r /grant:r "$env:USERNAME`:(R,W)" | Out-Null
        }
        else {
            chmod 600 $Path | Out-Null
        }
    }
    catch {
        Write-Host "INFO restrictive permissions could not be applied on this runner."
    }
}

$keystoreBase64 = Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_BASE64"
$keystorePassword = Get-RequiredEnvironmentValue "ANDROID_KEYSTORE_PASSWORD"
$keyAlias = Get-RequiredEnvironmentValue "ANDROID_KEY_ALIAS"
$keyPassword = Get-RequiredEnvironmentValue "ANDROID_KEY_PASSWORD"

if (-not (Test-Path -LiteralPath $RepoRoot -PathType Container)) {
    throw "Repo root not found: $RepoRoot"
}

New-Item -ItemType Directory -Force -Path $TempDirectory | Out-Null
$signingRoot = Join-Path $TempDirectory "android-release-signing"
New-Item -ItemType Directory -Force -Path $signingRoot | Out-Null

if (-not $KeyPropertiesPath) {
    $KeyPropertiesPath = Join-Path $RepoRoot "app/android/key.properties"
}

$keystorePath = Join-Path $signingRoot "upload-keystore.jks"
try {
    [System.IO.File]::WriteAllBytes($keystorePath, [Convert]::FromBase64String($keystoreBase64))
    Grant-RestrictiveAccess $keystorePath
    Write-PropertiesFile -Entries @{
        storePassword = $keystorePassword
        keyPassword = $keyPassword
        keyAlias = $keyAlias
        storeFile = $keystorePath
    } -Path $KeyPropertiesPath
    Grant-RestrictiveAccess $KeyPropertiesPath
    Write-Host "Signing keystore written to temporary path: $keystorePath"
    Write-Host "Signing properties written to: $KeyPropertiesPath"
}
catch {
    if (Test-Path -LiteralPath $KeyPropertiesPath) {
        Remove-Item -LiteralPath $KeyPropertiesPath -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $keystorePath) {
        Remove-Item -LiteralPath $keystorePath -Force -ErrorAction SilentlyContinue
    }
    throw
}
