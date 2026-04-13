# WindowsScripts

Windows PowerShell scripts to enhance privacy and security.  Windows Update
frequently resets privacy settings after major updates, so these scripts make
it quick and easy to re-apply them whenever needed.

---

## Quick start

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Apply-PrivacySettings.ps1
```

This runs all of the individual scripts in sequence and prints a summary at the
end.  **A reboot is recommended after running the script.**

---

## Scripts

| Script | What it does |
|--------|--------------|
| [`Apply-PrivacySettings.ps1`](Apply-PrivacySettings.ps1) | **Master script** – runs all scripts below in order. Use `-Skip` to omit specific scripts. |
| [`Disable-Telemetry.ps1`](Disable-Telemetry.ps1) | Minimises diagnostic/telemetry data sent to Microsoft; stops the DiagTrack service; disables CEIP, error reporting, and related scheduled tasks. |
| [`Disable-Cortana.ps1`](Disable-Cortana.ps1) | Disables Cortana, Bing web-search in the Start menu, and location/history access by the search service. |
| [`Disable-AdvertisingId.ps1`](Disable-AdvertisingId.ps1) | Disables the per-user advertising ID, personalised ads, Start menu suggestions, lock-screen ads, and sponsored app installs. |
| [`Disable-LocationTracking.ps1`](Disable-LocationTracking.ps1) | Turns off the system-wide location service and denies all app access to location data. |
| [`Configure-AppPermissions.ps1`](Configure-AppPermissions.ps1) | Denies app access to camera, microphone, contacts, calendar, call history, messaging, email, and other sensitive device capabilities. Disables Activity History and cloud clipboard sync. |
| [`Configure-SecuritySettings.ps1`](Configure-SecuritySettings.ps1) | Hardens security: disables SMBv1, AutoRun/AutoPlay, LLMNR, NetBIOS name resolution, Remote Registry, anonymous account enumeration, WDigest credential caching, and old TLS/SSL versions; maximises UAC; enables Windows Defender PUA and cloud protection. |

---

## Running individual scripts

Each script can also be run on its own:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Disable-Telemetry.ps1
```

### Skipping specific scripts

```powershell
.\Apply-PrivacySettings.ps1 -Skip Disable-Cortana, Configure-SecuritySettings
```

### WhatIf / dry-run mode

Every script supports `-WhatIf` so you can preview changes without applying them:

```powershell
.\Apply-PrivacySettings.ps1 -WhatIf
```

---

## Notes

- All scripts require **Administrator** privileges (`#Requires -RunAsAdministrator`).
- Settings are applied via registry keys and Group Policy paths so they survive
  user-profile resets.
- Windows Update (especially feature updates) may revert some settings — simply
  re-run `Apply-PrivacySettings.ps1` after each update.
- Some settings (e.g. disabling SMBv1 or old TLS versions) require a reboot to
  take full effect.

## License

[MIT](LICENSE)
