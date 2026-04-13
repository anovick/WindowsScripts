#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Applies all Windows privacy and security settings in one shot.

.DESCRIPTION
    Calls each individual script in sequence:
      1. Disable-Telemetry.ps1         – disables telemetry and diagnostic data
      2. Disable-Cortana.ps1           – disables Cortana and web search
      3. Disable-AdvertisingId.ps1     – disables advertising ID and personalised ads
      4. Disable-LocationTracking.ps1  – disables location services
      5. Configure-AppPermissions.ps1  – restricts app access to device capabilities
      6. Configure-SecuritySettings.ps1– hardens security settings

    Run this script after every Windows Update to restore your preferred settings.

.EXAMPLE
    # From an elevated PowerShell prompt:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\Apply-PrivacySettings.ps1

.NOTES
    Run as Administrator.
    A reboot is recommended after running this script.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    # Skip individual scripts by name (without .ps1 extension)
    [string[]]$Skip = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Ensure we are running elevated
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and choose 'Run as Administrator'."
    exit 1
}

$scriptDir = $PSScriptRoot

$scripts = @(
    'Disable-Telemetry',
    'Disable-Cortana',
    'Disable-AdvertisingId',
    'Disable-LocationTracking',
    'Configure-AppPermissions',
    'Configure-SecuritySettings'
)

$results = [ordered]@{}

foreach ($name in $scripts) {
    if ($Skip -contains $name) {
        Write-Host "  [$name] Skipped." -ForegroundColor DarkGray
        $results[$name] = 'Skipped'
        continue
    }

    $scriptPath = Join-Path $scriptDir "$name.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Warning "Script not found: $scriptPath"
        $results[$name] = 'Not found'
        continue
    }

    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Running: $name" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        & $scriptPath @PSBoundParameters
        $results[$name] = 'OK'
    }
    catch {
        Write-Warning "  [$name] failed: $_"
        $results[$name] = "FAILED: $_"
    }
}

# ----- Summary -----
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
foreach ($entry in $results.GetEnumerator()) {
    $color = switch -Wildcard ($entry.Value) {
        'OK'      { 'Green'    }
        'Skipped' { 'DarkGray' }
        'Not*'    { 'Yellow'   }
        default   { 'Red'      }
    }
    Write-Host ("  {0,-35} {1}" -f $entry.Key, $entry.Value) -ForegroundColor $color
}

Write-Host ""
Write-Host "  A reboot is recommended for all settings to take full effect." -ForegroundColor Yellow
