#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables the Windows Advertising ID and personalised advertisements.

.DESCRIPTION
    Turns off the per-user advertising identifier (similar to a mobile ad ID)
    that apps use to show targeted ads, and disables other ad-personalisation
    features such as tailored experiences and Start menu suggestions.

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

Write-Host "=== Disabling Advertising ID and Personalised Ads ===" -ForegroundColor Cyan

# ----- Advertising ID (current user) -----
Write-Host "  Disabling Advertising ID for current user..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0

# ----- Machine-wide policy -----
Write-Host "  Disabling Advertising ID via Group Policy..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1

# ----- Tailored experiences / tips using diagnostic data -----
Write-Host "  Disabling tailored experiences..."
Set-RegValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0

# ----- Start menu suggestions / sponsored apps -----
Write-Host "  Disabling Start menu app suggestions and sponsored apps..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338388Enabled' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-353698Enabled' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled'    0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled'      0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled'              0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed'          0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'OemPreInstalledAppsEnabled'      0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEnabled'         0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEverEnabled'     0

# ----- Lock-screen ads -----
Write-Host "  Disabling lock-screen ads (Windows Spotlight ads)..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenEnabled'       0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenOverlayEnabled' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338387Enabled'  0

# ----- "Get even more out of Windows" / Welcome Experience -----
Write-Host "  Disabling Windows welcome experiences..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-310093Enabled' 0

Write-Host "  Done." -ForegroundColor Green
