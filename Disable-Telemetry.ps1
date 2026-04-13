#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables Windows telemetry and diagnostic data collection.

.DESCRIPTION
    Configures registry keys and services to minimise the amount of
    diagnostic / telemetry data sent to Microsoft.  Windows Update can
    reset these settings, so re-run the script after every major update.

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

Write-Host "=== Disabling Windows Telemetry ===" -ForegroundColor Cyan

# ----- Diagnostic Data level -----
# 0 = Security (Enterprise/Education only), 1 = Basic/Required, 3 = Full
Write-Host "  Setting diagnostic data level to minimum (1 - Required)..."
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry'              1
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'MaxTelemetryAllowed'         1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'                'AllowTelemetry'              0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'                'LimitDiagnosticLogCollection' 1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'                'DisableOneSettingsDownloads'  1

# ----- Customer Experience Improvement Program (CEIP) -----
Write-Host "  Disabling Customer Experience Improvement Program (CEIP)..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows'          'CEIPEnable' 0

# ----- Application Telemetry -----
Write-Host "  Disabling Application Telemetry..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AITEnable'             0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableInventory'      1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisablePCA'            1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableUAR'            1

# ----- Error Reporting -----
Write-Host "  Disabling Windows Error Reporting..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled'       1
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontSendAdditionalData' 1
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'          'Disabled'       1

# ----- Feedback frequency -----
Write-Host "  Disabling feedback notifications..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds'  0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1

# ----- DiagTrack / Connected User Experiences service -----
Write-Host "  Stopping and disabling DiagTrack service..."
$diagTrack = Get-Service -Name 'DiagTrack' -ErrorAction SilentlyContinue
if ($diagTrack) {
    if ($PSCmdlet.ShouldProcess('DiagTrack', 'Stop and disable service')) {
        Stop-Service  -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue
        Set-Service   -Name 'DiagTrack' -StartupType Disabled
    }
}

# ----- dmwappushservice -----
Write-Host "  Stopping and disabling dmwappushservice..."
$dmwap = Get-Service -Name 'dmwappushservice' -ErrorAction SilentlyContinue
if ($dmwap) {
    if ($PSCmdlet.ShouldProcess('dmwappushservice', 'Stop and disable service')) {
        Stop-Service -Name 'dmwappushservice' -Force -ErrorAction SilentlyContinue
        Set-Service  -Name 'dmwappushservice' -StartupType Disabled
    }
}

# ----- Scheduled tasks that upload telemetry -----
Write-Host "  Disabling telemetry-related scheduled tasks..."
$tasks = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Application Experience\StartupAppTask',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
    '\Microsoft\Windows\Feedback\Siuf\DmClient',
    '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
    '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
    '\Microsoft\Windows\CloudExperienceHost\CreateObjectTask'
)
foreach ($task in $tasks) {
    if (Get-ScheduledTask -TaskPath (Split-Path $task -Parent) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue) {
        if ($PSCmdlet.ShouldProcess($task, 'Disable scheduled task')) {
            Disable-ScheduledTask -TaskPath (Split-Path $task -Parent) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

# ----- Delivery Optimization telemetry -----
Write-Host "  Restricting Delivery Optimization telemetry..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0

Write-Host "  Done." -ForegroundColor Green
