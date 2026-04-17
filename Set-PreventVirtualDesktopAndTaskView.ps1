# ================================================
# Disable Virtual Desktop Creation and Task View
# ================================================

# This is the powershell equivalent of the .cmd file that adds the keys this way
#reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDesktopCreation /t REG_DWORD /d 1 /f
#reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoTaskView /t REG_DWORD /d 1 /f"

$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"

# Create the Explorer Policies key if it doesn't exist
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Disable new desktop creation (Win + Ctrl + D)
New-ItemProperty -Path $RegPath -Name "NoDesktopCreation" -Value 1 -PropertyType DWord -Force | Out-Null

# Disable Task View (hides the Task View button and limits virtual desktops)
New-ItemProperty -Path $RegPath -Name "NoTaskView" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "Success: NoDesktopCreation and NoTaskView have been set to 1." -ForegroundColor Green
Write-Host "You may need to sign out and sign back in (or restart Explorer) for the changes to fully take effect." -ForegroundColor Yellow
