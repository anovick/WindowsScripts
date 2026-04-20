# WindowsScripts

Windows scripts to help with privacy, security, and Windows managment. 

---

You may want to start with other utilities that do a more comprehensive job on Windows settings.   Check out these utilities first:

- Windows Toolbox by Chris Titus Tech  https://christitus.com/ 

- Winero Tweaker https://winaerotweaker.com/

---

The scripts must be run in a PowerShell session started with Run as Administrator.
You may also need to remove the restriction on running PowerShell scripts with this PowerShell line:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

There are two groups of scripts:

1. One-time scripts

2. Run regularly

---

## Group 1 - One-Time Scripts

### Update-PowerShell.ps1

Updates PowerShell to version 7

### Set-PreventVirtualDesktopAndTaskView.ps1

Prevents the creation of Virtual Desktops and TaskView.   This might be used in VMs where you don't want virtual desktops because you're using virtual desktops on the host OS.

---

## Group 2 - Run regularly

Run these after every Windows update or even more frequently. 

### Run-Regularly.ps1

Runs all the scripts in Group 2

### Set-WindowsUpdateDeferral.ps1

Pauses Windows Update for 28 days on Feature Updates  and 4 days on Quality Updates, which are usually for security.

### Set-WindowsStoreSupression.ps1

Does these steps to suppress Windows Store

- Removes Store from Start menu for all users

- Disables Store via group policy equivalent registry keys

- Removes Store autostart/background tasks

- Prevents Store from reinstalling itself via scheduled tasks

- Cleans up any existing Store processes

### Set-PowerPlanHigh.ps1

Turns up the power plan to High to maximize performance

### Set-NoInkingAndTypingDataCollection.ps1

Turn off the constant telemetry about keystrokes and pen movements.
