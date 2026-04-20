#Requires -RunAsAdministrator

Write-Host ""
Write-Host "Starting all regulary scripts." -ForegroundColor Cyan
Write-Host ""

# Defer Windows Update for 28 days on feature updates and 4 days on security opdates
.\Set-WindowsUpdateDeferral.ps1

# Supress the Windows Store
.\Set-WindowsStoreSupression.ps1

# Power plan for maximum performance
.\Set-PowerPlanHigh.ps1

# Turn off telemetry for keyboard use and ink strokes
.\Set-NoInkingAndTypingDataCollection.ps1

Write-Host ""
Write-Host "Recommended actions:" -ForegroundColor Cyan
Write-Host "• Sign out and sign back in (or restart) for all changes to fully apply."


