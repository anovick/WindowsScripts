#Requires -RunAsAdministrator

Write-Host "Disabling Microsoft Inking & Typing data collection (TIPC and InputPersonalization)..." -ForegroundColor Yellow

# === TIPC: Improve inking and typing recognition ===

# Current User (HKCU)
$tipcCU = "HKCU:\Software\Microsoft\Input\TIPC"
if (-not (Test-Path $tipcCU)) { New-Item -Path $tipcCU -Force | Out-Null }
Set-ItemProperty -Path $tipcCU -Name "Enabled" -Value 0 -Type DWord -Force

# System-wide (HKLM) - affects all users
$tipcLM = "HKLM:\SOFTWARE\Microsoft\Input\TIPC"
if (-not (Test-Path $tipcLM)) { New-Item -Path $tipcLM -Force | Out-Null }
Set-ItemProperty -Path $tipcLM -Name "Enabled" -Value 0 -Type DWord -Force

# === InputPersonalization: Restrict implicit ink & text collection ===

# Current User (HKCU)
$ipCU = "HKCU:\Software\Microsoft\InputPersonalization"
if (-not (Test-Path $ipCU)) { New-Item -Path $ipCU -Force | Out-Null }
Set-ItemProperty -Path $ipCU -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $ipCU -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -Force

# Also disable trained data harvesting (optional but recommended)
$trainedCU = "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
if (-not (Test-Path $trainedCU)) { New-Item -Path $trainedCU -Force | Out-Null }
Set-ItemProperty -Path $trainedCU -Name "HarvestContacts" -Value 0 -Type DWord -Force

# System-wide / Policy (HKLM) - stronger enforcement
$ipLM = "HKLM:\SOFTWARE\Microsoft\InputPersonalization"
if (-not (Test-Path $ipLM)) { New-Item -Path $ipLM -Force | Out-Null }
Set-ItemProperty -Path $ipLM -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $ipLM -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -Force

# Additional policy location (often used by Group Policy / enterprise)
$policyLM = "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"
if (-not (Test-Path $policyLM)) { New-Item -Path $policyLM -Force | Out-Null }
Set-ItemProperty -Path $policyLM -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $policyLM -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -Force

Write-Host "Settings have been disabled successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Recommended actions:" -ForegroundColor Cyan
Write-Host "• Sign out and sign back in (or restart the computer) for changes to fully apply."
Write-Host "• You can verify the settings in: Settings > Privacy & security > Inking & typing personalization"
Write-Host "• These changes prevent Windows from sending your inking and typing samples to Microsoft."

# Optional: Force a refresh (not always required)
# Stop-Process -Name "TextInputHost" -Force -ErrorAction SilentlyContinue
