#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Hardens Windows security settings.

.DESCRIPTION
    Applies a set of security hardening tweaks:
      - Disables SMBv1 (a common ransomware attack vector)
      - Disables AutoRun / AutoPlay
      - Disables LLMNR and NetBIOS-based name resolution (prevents poisoning)
      - Disables Remote Registry service
      - Disables anonymous enumeration of shares and accounts
      - Enables UAC at the highest practical level
      - Enables Windows Defender PUA protection and cloud-delivered protection
      - Disables outdated / insecure TLS/SSL versions

.NOTES
    Run as Administrator.
    Tested on Windows 10 / Windows 11.
    Some settings (e.g. SMBv1) require a reboot to take effect.
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

Write-Host "=== Hardening Windows Security Settings ===" -ForegroundColor Cyan

# ----- SMBv1 -----
Write-Host "  Disabling SMBv1 (EternalBlue / ransomware vector)..."
if ($PSCmdlet.ShouldProcess('SMBv1', 'Disable')) {
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue
    Disable-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol' -NoRestart -ErrorAction SilentlyContinue | Out-Null
}
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'SMB1' 0

# ----- AutoRun / AutoPlay -----
Write-Host "  Disabling AutoRun and AutoPlay..."
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'                'NoAutoplayfornonVolume' 1
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun'          1

# ----- LLMNR (Link-Local Multicast Name Resolution) -----
Write-Host "  Disabling LLMNR (prevents LLMNR poisoning attacks)..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 0

# ----- NetBIOS over TCP/IP -----
Write-Host "  Disabling NetBIOS over TCP/IP on all adapters..."
$adapters = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces'
foreach ($adapter in $adapters) {
    if ($PSCmdlet.ShouldProcess($adapter.PSPath, 'Disable NetBIOS')) {
        Set-ItemProperty -Path $adapter.PSPath -Name 'NetbiosOptions' -Value 2 -Type DWord -Force
    }
}

# ----- Remote Registry -----
Write-Host "  Disabling Remote Registry service..."
$remReg = Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue
if ($remReg) {
    if ($PSCmdlet.ShouldProcess('RemoteRegistry', 'Stop and disable service')) {
        Stop-Service  -Name 'RemoteRegistry' -Force -ErrorAction SilentlyContinue
        Set-Service   -Name 'RemoteRegistry' -StartupType Disabled
    }
}

# ----- Anonymous enumeration of SAM accounts / shares -----
Write-Host "  Blocking anonymous enumeration of accounts and shares..."
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymous'        1
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymousSAM'     1
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'EveryoneIncludesAnonymous' 0

# ----- UAC -----
Write-Host "  Setting UAC to maximum (prompt on secure desktop)..."
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableLUA'                  1
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorAdmin' 2
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorUser'  0
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'PromptOnSecureDesktop'      1

# ----- Windows Defender – PUA (Potentially Unwanted Application) protection -----
Write-Host "  Enabling Windows Defender PUA protection..."
if ($PSCmdlet.ShouldProcess('Windows Defender', 'Enable PUA protection')) {
    Set-MpPreference -PUAProtection Enabled -ErrorAction SilentlyContinue
}
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' 'PUAProtection' 1

# ----- Windows Defender – cloud-delivered protection -----
Write-Host "  Enabling cloud-delivered protection and automatic sample submission..."
if ($PSCmdlet.ShouldProcess('Windows Defender', 'Enable cloud protection')) {
    Set-MpPreference -MAPSReporting Advanced           -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent SendSafeSamples -ErrorAction SilentlyContinue
    Set-MpPreference -CloudBlockLevel High             -ErrorAction SilentlyContinue
}

# ----- Disable outdated TLS/SSL versions -----
Write-Host "  Disabling SSL 2.0, SSL 3.0, TLS 1.0, and TLS 1.1..."
$protoBase = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
$oldProtocols = @('SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1')
foreach ($proto in $oldProtocols) {
    Set-RegValue "$protoBase\$proto\Server" 'Enabled'        0
    Set-RegValue "$protoBase\$proto\Server" 'DisabledByDefault' 1
    Set-RegValue "$protoBase\$proto\Client" 'Enabled'        0
    Set-RegValue "$protoBase\$proto\Client" 'DisabledByDefault' 1
}

# Ensure TLS 1.2 and 1.3 are explicitly enabled
foreach ($proto in @('TLS 1.2', 'TLS 1.3')) {
    Set-RegValue "$protoBase\$proto\Server" 'Enabled'        1
    Set-RegValue "$protoBase\$proto\Server" 'DisabledByDefault' 0
    Set-RegValue "$protoBase\$proto\Client" 'Enabled'        1
    Set-RegValue "$protoBase\$proto\Client" 'DisabledByDefault' 0
}

# ----- Windows Script Host (optional hardening note) -----
Write-Host "  Restricting Windows Script Host..."
Set-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings' 'Enabled' 0

# ----- Disable WDigest credential caching -----
Write-Host "  Disabling WDigest plaintext credential caching..."
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' 'UseLogonCredential' 0

Write-Host ""
Write-Host "  Done. A reboot is recommended for all settings to take effect." -ForegroundColor Green
