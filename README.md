# Windows Admin Scripts

PowerShell scripts for managing WSL, SSH, and user privileges on Windows.

## Scripts

### wsl-restart-and-keepalive.ps1

Force restart a hanging WSL instance and optionally create a scheduled task to keep WiFi alive.

```powershell
.\wsl-restart-and-keepalive.ps1
```

**Requires:** Admin

**Actions:**
- Kills wsl, wslhost, wslservice processes
- Runs `wsl --shutdown`
- Restarts WSL service (auto-detects `wslservice` or `LxssManager`)
- Creates `WiFi-KeepAlive-Ping` scheduled task (pings 192.168.50.1 every 2 min)

**Remove the ping task:**
```powershell
Unregister-ScheduledTask -TaskName "WiFi-KeepAlive-Ping" -Confirm:$false
```

---

### restart-sshd-2222.ps1

Configure and restart Windows OpenSSH server on port 2222 with LAN access.

```powershell
.\restart-sshd-2222.ps1
```

**Requires:** Admin, OpenSSH Server installed

**Actions:**
- Sets `Port 2222` and `ListenAddress 0.0.0.0` in sshd_config
- Restarts sshd service, sets to auto-start
- Creates firewall rule for TCP 2222 (Private/Domain networks only)
- Displays connection command for other devices

**Troubleshooting:**
```powershell
# Test config for errors
sshd -t -f "C:\ProgramData\ssh\sshd_config"

# Check what's using the port
Get-NetTCPConnection -LocalPort 2222 -State Listen
```

**Note:** SSH uses your Windows account password, not PIN or Windows Hello.

---

### sudo.ps1

Run commands with elevated privileges over SSH (no UAC prompt).

```powershell
sudo Get-Service sshd
sudo Restart-Service sshd
sudo netstat -an
```

**Requires:** Script in PATH

**Setup:**
```powershell
mkdir C:\bin -ErrorAction SilentlyContinue
Copy-Item sudo.ps1 C:\bin\
Set-Content -Path "C:\bin\sudo.cmd" -Value '@powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sudo.ps1" %*'
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\bin", "Machine")
```

**How it works:** Creates a temporary scheduled task that runs as SYSTEM, captures output, then cleans up.

**Limitation:** Runs as SYSTEM, not your user — user-specific operations won't work.

---

### admin-grant.ps1

Temporarily add a user to the Administrators group.

```powershell
.\admin-grant.ps1              # 30 minutes (default)
.\admin-grant.ps1 -Minutes 60  # 1 hour
```

**Requires:** Admin

**Actions:**
- Adds `snake` to Administrators group
- Schedules automatic removal after X minutes
- User must reconnect SSH for changes to take effect

---

### admin-revoke.ps1

Manually remove a user from Administrators before the timer expires.

```powershell
.\admin-revoke.ps1
```

**Requires:** Admin

---

### admin-status.ps1

Check if the user currently has admin privileges and when they expire.

```powershell
.\admin-status.ps1
```

**Example output:**
```
snake is currently in Administrators
Auto-revoke scheduled: 2/14/2026 3:45:00 PM
```

---

## Temporary Admin Workflow

1. Admin (mdavi) grants access:
   ```powershell
   .\admin-grant.ps1 -Minutes 60
   ```

2. User (snake) disconnects and reconnects SSH

3. User now has full admin — all commands run elevated automatically

4. After timeout (or manual revoke), access is removed

5. User reconnects to drop back to normal privileges

---

## Execution Policy

If scripts won't run due to signing policy:

```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
```

---

## Installation

Copy all scripts to a directory in your PATH:

```powershell
mkdir C:\bin -ErrorAction SilentlyContinue
Copy-Item *.ps1 C:\bin\
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\bin", "Machine")
```
