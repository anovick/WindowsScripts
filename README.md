# WindowsScripts

Windows scripts to help with privacy, security, and Windows managment.   There supplement utilities that do a more comprehensive job on Windows settings.   Check out these utilites first:

- Windows Toolbox by Chris Titus Tech (paid)  https://christitus.com/ 

- Winero Tweaker https://winaerotweaker.com/



These should be run in a powershell session started with Run as Administrator.
You may also need to remove the restriction on running powershell scripts with this:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Set-PreventVirtualDesktopAndTaskView.ps1

Prevents the creation of Virtual Desktops and showin TaskView.   This might be used in VMs where you don't want virtual desktops.

## Set-WindowsUpdateDeferral.ps1

Pauses Windows Update for 28 days on Feature Updates  and 4 days on Quality Updates, which are usually for security.

## Set-WindowsStoreSupression.ps1

- Does thes steps to suppress Windows Store

- Removes Store from Start menu for all users

- Disables Store via group policy equivalent registry keys

- Removes Store autostart/background tasks

- Prevents Store from reinstalling itself via scheduled tasks

- Cleans up any existing Store processes
