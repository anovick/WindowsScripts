#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Restricts app access to sensitive device capabilities.

.DESCRIPTION
    Configures Windows privacy settings (camera, microphone, contacts,
    calendar, call history, messaging, account info, etc.) so that apps
    must request permission before accessing them, and sets safe defaults
    where Windows Update frequently resets them.

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

# Helper: deny a capability for the whole system and the current user
function Deny-Capability {
    param([string]$Capability)
    $machinePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$Capability"
    $userPath    = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$Capability"
    Set-RegValue $machinePath 'Value' 'Deny' 'String'
    Set-RegValue $userPath    'Value' 'Deny' 'String'
}

Write-Host "=== Configuring App Permissions ===" -ForegroundColor Cyan

# ----- Camera -----
Write-Host "  Denying app camera access..."
Deny-Capability 'webcam'

# ----- Microphone -----
Write-Host "  Denying app microphone access..."
Deny-Capability 'microphone'

# ----- Account info -----
Write-Host "  Denying app access to account info..."
Deny-Capability 'userAccountInformation'

# ----- Contacts -----
Write-Host "  Denying app access to contacts..."
Deny-Capability 'contacts'

# ----- Calendar -----
Write-Host "  Denying app access to calendar..."
Deny-Capability 'appointments'

# ----- Call history -----
Write-Host "  Denying app access to call history..."
Deny-Capability 'phoneCall'
Deny-Capability 'phoneCallHistory'

# ----- Messaging (SMS/MMS) -----
Write-Host "  Denying app access to messaging..."
Deny-Capability 'chat'

# ----- Email -----
Write-Host "  Denying app access to email..."
Deny-Capability 'email'

# ----- Tasks / to-do -----
Write-Host "  Denying app access to tasks..."
Deny-Capability 'userDataTasks'

# ----- Documents library -----
Write-Host "  Denying broad document library access..."
Deny-Capability 'documentsLibrary'

# ----- Downloads folder -----
Write-Host "  Denying broad downloads folder access..."
Deny-Capability 'downloadsFolder'

# ----- Pictures library -----
Write-Host "  Denying broad pictures library access..."
Deny-Capability 'picturesLibrary'

# ----- Videos library -----
Write-Host "  Denying broad videos library access..."
Deny-Capability 'videosLibrary'

# ----- Notifications -----
Write-Host "  Restricting notification access..."
Deny-Capability 'userNotificationListener'

# ----- Radios (Bluetooth / Wi-Fi control by apps) -----
Write-Host "  Denying app radio (Bluetooth/Wi-Fi) control..."
Deny-Capability 'radios'

# ----- Activity history / Timeline -----
Write-Host "  Disabling Activity History..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed'         0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities'      0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities'       0

# ----- Shared experiences / Cross-device clipboard -----
Write-Host "  Disabling cross-device shared experiences..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableCdp' 0

# ----- Cloud clipboard (clipboard history sync) -----
Write-Host "  Disabling cloud clipboard sync..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Clipboard' 'EnableClipboardHistory' 0

Write-Host "  Done." -ForegroundColor Green
