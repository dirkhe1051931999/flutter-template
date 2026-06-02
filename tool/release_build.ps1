param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('apk', 'windows', 'web', 'all')]
  [string]$Platform,

  [ValidateSet('patch', 'minor', 'major')]
  [string]$Bump = 'patch',

  [switch]$SkipBuild,
  [switch]$SkipVersionBump
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PubspecVersion {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PubspecPath
  )

  $content = Get-Content -Raw -LiteralPath $PubspecPath
  $match = [regex]::Match($content, "(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$")

  if (-not $match.Success) {
    throw "Unable to read version from $PubspecPath"
  }

  return [PSCustomObject]@{
    Major = [int]$match.Groups[1].Value
    Minor = [int]$match.Groups[2].Value
    Patch = [int]$match.Groups[3].Value
    Name = "$($match.Groups[1].Value).$($match.Groups[2].Value).$($match.Groups[3].Value)"
    BuildNumber = [int]$match.Groups[4].Value
  }
}

function Set-PubspecVersion {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PubspecPath,
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [Parameter(Mandatory = $true)]
    [int]$BuildNumber
  )

  $content = Get-Content -Raw -LiteralPath $PubspecPath
  $updated = [regex]::Replace(
    $content,
    "(?m)^version:\s*\d+\.\d+\.\d+\+\d+\s*$",
    "version: $Version+$BuildNumber",
    1
  )

  if ($updated -eq $content) {
    throw "Failed to update version in $PubspecPath"
  }

  Set-Content -LiteralPath $PubspecPath -Value $updated -Encoding UTF8NoBOM
}

function Get-NextVersion {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$VersionInfo,
    [Parameter(Mandatory = $true)]
    [string]$BumpType
  )

  switch ($BumpType) {
    'patch' {
      return "$($VersionInfo.Major).$($VersionInfo.Minor).$($VersionInfo.Patch + 1)"
    }
    'minor' {
      return "$($VersionInfo.Major).$($VersionInfo.Minor + 1).0"
    }
    'major' {
      return "$($VersionInfo.Major + 1).0.0"
    }
    default {
      throw "Unsupported bump type: $BumpType"
    }
  }
}

function Invoke-FlutterBuild {
  param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPlatform,
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [Parameter(Mandatory = $true)]
    [int]$BuildNumber
  )

  $arguments = @('build', $TargetPlatform, '--build-name', $Version, '--build-number', "$BuildNumber")

  & flutter @arguments

  if ($LASTEXITCODE -ne 0) {
    throw "flutter build $TargetPlatform failed with exit code $LASTEXITCODE"
  }
}

function Copy-BuildArtifact {
  param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPlatform,
    [Parameter(Mandatory = $true)]
    [string]$ArtifactBaseName,
    [Parameter(Mandatory = $true)]
    [string]$ReleaseRoot
  )

  New-Item -ItemType Directory -Path $ReleaseRoot -Force | Out-Null

  switch ($TargetPlatform) {
    'apk' {
      $sourcePath = Join-Path $PSScriptRoot '..\build\app\outputs\flutter-apk\app-release.apk'
      $destinationPath = Join-Path $ReleaseRoot "$ArtifactBaseName.apk"
      if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Build artifact not found: $sourcePath. Run flutter build apk first, or omit -SkipBuild."
      }
      Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
      return $destinationPath
    }
    'windows' {
      $sourcePath = Join-Path $PSScriptRoot '..\build\windows\x64\runner\Release'
      $destinationPath = Join-Path $ReleaseRoot $ArtifactBaseName
      if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Build artifact not found: $sourcePath. Run flutter build windows first, or omit -SkipBuild."
      }
      if (Test-Path -LiteralPath $destinationPath) {
        Remove-Item -LiteralPath $destinationPath -Recurse -Force
      }
      Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Recurse -Force
      return $destinationPath
    }
    'web' {
      $sourcePath = Join-Path $PSScriptRoot '..\build\web'
      $destinationPath = Join-Path $ReleaseRoot $ArtifactBaseName
      if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Build artifact not found: $sourcePath. Run flutter build web first, or omit -SkipBuild."
      }
      if (Test-Path -LiteralPath $destinationPath) {
        Remove-Item -LiteralPath $destinationPath -Recurse -Force
      }
      Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Recurse -Force
      return $destinationPath
    }
    default {
      throw "Unsupported platform: $TargetPlatform"
    }
  }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$releaseRoot = Join-Path $repoRoot 'dist\releases'
$versionInfo = Get-PubspecVersion -PubspecPath $pubspecPath
$timestamp = Get-Date -Format 'yyyyMMdd HH'
$artifactBaseName = "oolaf flutted $($versionInfo.Name) $timestamp"

$platforms = if ($Platform -eq 'all') {
  @('apk', 'windows', 'web')
} else {
  @($Platform)
}

$artifactPaths = @()

foreach ($targetPlatform in $platforms) {
  if (-not $SkipBuild) {
    Invoke-FlutterBuild -TargetPlatform $targetPlatform -Version $versionInfo.Name -BuildNumber $versionInfo.BuildNumber
  }

  $artifactPath = Copy-BuildArtifact -TargetPlatform $targetPlatform -ArtifactBaseName $artifactBaseName -ReleaseRoot $releaseRoot
  $artifactPaths += $artifactPath
}

if (-not $SkipVersionBump) {
  $nextVersion = Get-NextVersion -VersionInfo $versionInfo -BumpType $Bump
  $nextBuildNumber = $versionInfo.BuildNumber + 1
  Set-PubspecVersion -PubspecPath $pubspecPath -Version $nextVersion -BuildNumber $nextBuildNumber
}

Write-Host 'Release artifacts:'
foreach ($artifactPath in $artifactPaths) {
  Write-Host "- $artifactPath"
}
