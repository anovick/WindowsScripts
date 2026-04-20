#Requires -RunAsAdministrator

Write-Host "=== PowerShell Updater for Windows 11 ===" -ForegroundColor Cyan
Write-Host "This script will check and update PowerShell 7+ using winget (recommended method).`n"

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install the App Installer from the Microsoft Store or run Windows Update." -ForegroundColor Yellow
    exit 1
}

# Check current PowerShell 7 version (if installed)
$pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwshPath) {
    $currentVersion = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
    Write-Host "Current PowerShell 7 version: $currentVersion" -ForegroundColor Green
} else {
    Write-Host "PowerShell 7 is not currently installed." -ForegroundColor Yellow
}

# Check for available upgrade
Write-Host "`nChecking for PowerShell updates..." -ForegroundColor Yellow
$upgradeCheck = winget list --id Microsoft.PowerShell --upgrade-available --accept-source-agreements 2>&1

if ($upgradeCheck -match "No installed package found" -or $upgradeCheck -match "upgrade available") {
    Write-Host "An update (or fresh install) for PowerShell is available." -ForegroundColor Green
    
    $confirm = Read-Host "Do you want to proceed with the update/install? (Y/N)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "`nUpdating/Installing PowerShell 7+ ..." -ForegroundColor Cyan
    winget upgrade --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nPowerShell has been successfully updated/installed!" -ForegroundColor Green
    } else {
        Write-Host "`nUpdate completed with warnings or errors (exit code: $LASTEXITCODE)." -ForegroundColor Yellow
    }
} else {
    Write-Host "PowerShell is already up to date or no upgrade is available." -ForegroundColor Green
}

# Final verification
Write-Host "`n=== Verification ===" -ForegroundColor Cyan
Write-Host "Run the following commands in a new window to check versions:"
Write-Host "   pwsh -Version                  # For PowerShell 7+" -ForegroundColor White
Write-Host "   powershell -Version            # For built-in Windows PowerShell 5.1" -ForegroundColor White

Write-Host "`nTip: You can now launch the latest PowerShell by typing 'pwsh' in the Start menu or Run dialog." -ForegroundColor Gray