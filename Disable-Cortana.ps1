#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables Cortana and web-search integration in the Windows Start menu.

.DESCRIPTION
    Applies registry and Group Policy settings to turn off Cortana and
    prevent the Start menu / taskbar search from sending queries to Bing.

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

Write-Host "=== Disabling Cortana and Web Search ===" -ForegroundColor Cyan

# ----- Cortana (machine-wide policy) -----
Write-Host "  Disabling Cortana via Group Policy..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana'                       0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortanaAboveLock'              0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowSearchToUseLocation'           0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb'              0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWebOverMeteredConnections' 0
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch'                   1

# ----- Cortana (current user) -----
Write-Host "  Disabling Cortana for current user..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'CortanaEnabled'      0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled'   0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'AllowSearchToUseLocation' 0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'HistoryViewEnabled'  0
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'DeviceHistoryEnabled' 0

# ----- Disable Cortana in Lock screen -----
Write-Host "  Disabling Cortana on Lock screen..."
Set-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortanaAboveLock' 0

# ----- Disable Cortana consent store -----
Write-Host "  Disabling Cortana consent..."
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'CanCortanaBeEnabled' 0

# ----- Windows 11: disable taskbar search box / web results -----
Write-Host "  Disabling taskbar web search (Windows 11)..."
Set-RegValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
Set-RegValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 1

Write-Host "  Done." -ForegroundColor Green
