# ================================================
# You must run this script as Administrator
# Defer feature updates: 28 days (4 weeks)
# Defer quality updates: 4 days
# Runs as Administrator required
# 2026-04-16 with the aid of SuperGrok
# ================================================

# Check Execution Policy first
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq 'Restricted') {
    Write-Host "ERROR: PowerShell Execution Policy is still Restricted." -ForegroundColor Red
    Write-Host "Please run this command once in an elevated PowerShell window first:" -ForegroundColor Yellow
    Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
    Write-Host "`nAfter that, run this script again." -ForegroundColor Yellow
    exit
}

# Require Administrator rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Please run this script as Administrator." -ForegroundColor Red
    exit
}

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Create the path if it doesn't exist
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set deferral periods
Set-ItemProperty -Path $RegPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 28 -Type DWord -Force
Set-ItemProperty -Path $RegPath -Name "DeferQualityUpdatesPeriodInDays" -Value 4 -Type DWord -Force

# Optional safety net: Pause updates for 35 days
$pauseExpiry = (Get-Date).AddDays(35).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$pauseStart  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$UXPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
if (-not (Test-Path $UXPath)) {
    New-Item -Path $UXPath -Force | Out-Null
}
Set-ItemProperty -Path $UXPath -Name "PauseUpdatesExpiryTime" -Value $pauseExpiry -Force
Set-ItemProperty -Path $UXPath -Name "PauseFeatureUpdatesStartTime" -Value $pauseStart -Force

Write-Host "`nSuccess! Windows Update deferral settings have been applied:" -ForegroundColor Green
Write-Host "   • Feature updates deferred for 28 days" -ForegroundColor Green
Write-Host "   • Quality updates deferred for 4 days" -ForegroundColor Green
Write-Host "   • 35-day pause safety net activated" -ForegroundColor Green

Write-Host "`nYou can now manually install updates anytime via Settings → Windows Update." -ForegroundColor Yellow

# Restart Windows Update service to apply changes
Restart-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Write-Host "`nWindows Update service has been restarted." -ForegroundColor Green

# Verification
Write-Host "`nTo verify the settings, run this command later:" -ForegroundColor Cyan
Write-Host "   Get-ItemProperty -Path '$RegPath' | Select-Object DeferFeatureUpdatesPeriodInDays, DeferQualityUpdatesPeriodInDays" -ForegroundColor Cyan

