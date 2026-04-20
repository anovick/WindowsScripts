<#
.SYNOPSIS
    Sets the Windows power plan to High Performance and configures:
    - Turn off the display: Never (for both AC and DC power)
    - Put the computer to sleep: Never (for both AC and DC power)

.NOTES
    Run this script as Administrator.
    On some Windows 11 systems (especially those using Modern Standby), the "High Performance" plan may not be visible by default.
    The script will attempt to restore it if missing.
#>

#Requires -RunAsAdministrator

Write-Host "Setting power plan to High Performance and configuring timeouts..." -ForegroundColor Cyan

# GUID for the built-in High Performance power plan
$highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

# Ensure the High Performance plan exists (restore it if missing)
$existingPlans = powercfg /list
if ($existingPlans -notmatch $highPerfGuid) {
    Write-Host "High Performance plan not found. Restoring it..." -ForegroundColor Yellow
    powercfg -duplicatescheme $highPerfGuid | Out-Null
}

# Set the active power plan to High Performance
powercfg /setactive $highPerfGuid

# Verify the active plan
$activePlan = powercfg /getactivescheme
Write-Host "Active power plan set to: $($activePlan)" -ForegroundColor Green

# Set "Turn off the display" to Never (0 minutes) for both plugged in (AC) and on battery (DC)
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0

# Set "Put the computer to sleep" to Never (0 minutes) for both AC and DC
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0

# Optional: Also prevent hard disk from turning off (common companion setting)
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

Write-Host "`nPower settings updated successfully!" -ForegroundColor Green
Write-Host "  • Power plan: High Performance" -ForegroundColor Green
Write-Host "  • Turn off the display: Never" -ForegroundColor Green
Write-Host "  • Put the computer to sleep: Never" -ForegroundColor Green

# Optional: Show current settings for verification
Write-Host "`nCurrent relevant power settings:" -ForegroundColor Cyan
powercfg /query | Select-String -Pattern "monitor-timeout|standby-timeout|Power Scheme GUID" -Context 0,2
