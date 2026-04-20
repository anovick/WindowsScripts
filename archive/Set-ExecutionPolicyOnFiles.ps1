# Set the exeution policy so that these particular scripts can be run even if the System or User policy isn't set to allow it.

Write-Host "Setting Exeuction Policy to allow Set-UpdateDeferral.ps1 to run"
powershell -ExecutionPolicy Bypass -File "Z:\Code\WindowsScripts\Set-WindowsUpdateDeferral.ps1"

Write-Host "`nExecution Policy on files has been changed and the files have been run."




