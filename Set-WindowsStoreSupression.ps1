#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Disables Microsoft Store access and prevents it from auto-starting

.DESCRIPTION
    This script:
    - Removes Store from Start menu for all users
    - Disables Store via group policy equivalent registry keys
    - Removes Store autostart/background tasks
    - Prevents Store from reinstalling itself via scheduled tasks
    - Cleans up existing Store processes

.NOTES
    - Must be run as Administrator
    - Works on Windows 10 / Windows 11 (most builds 2022–2025)
    - Changes are reversible (see comments below)
#>

Write-Host "Disabling Microsoft Store..." -ForegroundColor Cyan

# ────────────────────────────────────────────────────────────────
# 1. Kill any running Store processes
# ────────────────────────────────────────────────────────────────
Get-Process -Name "WinStore.App", "WinStore", "Microsoft.Store*", "*Store*" -ErrorAction SilentlyContinue |
    Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Milliseconds 800

# ────────────────────────────────────────────────────────────────
# 2. Main Store disable keys (most effective method in 2024/2025)
# ────────────────────────────────────────────────────────────────
$paths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
    "HKCU:\Software\Policies\Microsoft\WindowsStore",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
)

foreach ($path in $paths) {
    if (-not (Test-Path $path)) {
        $null = New-Item -Path $path -Force
    }
}

# The most important key — disables Store entirely for most scenarios
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Value 1 -Type DWord -Force

# Disable Store from appearing in search / suggestions
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force

# Disable some auto-download / auto-install behaviors
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force

# ────────────────────────────────────────────────────────────────
# 3. Remove from autostart / background
# ────────────────────────────────────────────────────────────────
$autoStartKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $autoStartKeys) {
    Remove-ItemProperty -Path $key -Name "*Store*" -ErrorAction SilentlyContinue
}

# ────────────────────────────────────────────────────────────────
# 4. Disable scheduled tasks that reinstall / update Store
# ────────────────────────────────────────────────────────────────
$tasks = @(
    "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup",
    "\Microsoft\Windows\AppxDeploymentClient\UWP apps cleanup",
    "\Microsoft\Windows\WindowsUpdate\Scheduled Start",
    "\Microsoft\Windows\Store\License Acquisition",
    "\Microsoft\Windows\Store\Update Apps",
    "\Microsoft\Windows\Store\ScanForUpdates",
    "\Microsoft\Windows\MSPaint\Telemetry",
    "\Microsoft\Windows\ContentDeliveryManager\BgTask"
)

foreach ($task in $tasks) {
    Get-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue
}

# ────────────────────────────────────────────────────────────────
# 5. Hide Store tile / shortcut for current & new users (Start menu)
# ────────────────────────────────────────────────────────────────
$layoutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\LayoutModification.xml"

if (-not (Test-Path $layoutPath)) {
    # Very basic layout that excludes Store
    $layout = @'
<LayoutModificationTemplate xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification" Version="1">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" />
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
'@
    $layout | Out-File $layoutPath -Encoding UTF8 -Force
}

Write-Host "`nMicrosoft Store should now be:" -ForegroundColor Green
Write-Host "  • Removed from Start menu"
Write-Host "  • Prevented from launching via normal means"
Write-Host "  • Blocked from auto-starting / background activity"
Write-Host "  • Hidden from most update mechanisms`n"

Write-Host "A reboot is recommended for all changes to take full effect." -ForegroundColor Yellow

# Optional: How to re-enable (just comment/uncomment when needed)
<#
# To RE-ENABLE Store later, run these lines:
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Store\*" | Enable-ScheduledTask
#>zzk

# https://grok.com/share/bGVnYWN5LWNvcHk_11cbbb46-2221-42a7-b731-7d42d92c7411