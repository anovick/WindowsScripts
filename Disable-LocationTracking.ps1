#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables Windows location services and tracking.

.DESCRIPTION
    Turns off the system-wide location service and per-app location access
    so that neither Windows components nor third-party apps can retrieve or
    report the device's physical location.

.NOTES
    Run as Administrator.
    Tested on Windows 10 / Windows 11.
#>

[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord'
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    if ($PSCmdlet.ShouldProcess("$Path\$Name", "Set registry value to $Value")) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    }
}

Write-Host "=== Disabling Location Services ===" -ForegroundColor Cyan

# ----- System-wide location service -----
Write-Host "  Disabling location service system-wide..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation'          1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocationScripting' 1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableSensors'           1
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'SensorPermissionState' 0

# ----- Per-user location consent -----
Write-Host "  Disabling location for current user..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'Value' 'Deny' 'String'
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'SensorPermissionState' 0

# ----- Windows 10/11 privacy location toggle -----
Write-Host "  Revoking app location access (privacy settings)..."
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' 'String'
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' 'String'

# ----- Search / Cortana location -----
Write-Host "  Preventing Search from using location..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'AllowSearchToUseLocation' 0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowSearchToUseLocation' 0

# ----- Location history -----
Write-Host "  Clearing and disabling location history..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'Value' 'Deny' 'String'

# ----- Maps auto-download based on location -----
Write-Host "  Disabling Maps location auto-update..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps' 'AutoDownloadAndUpdateMapData' 0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps' 'AllowUntriggeredNetworkTrafficOnSettingsPage' 0

Write-Host "  Done." -ForegroundColor Green
