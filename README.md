This is just a dirty work around for when you need to add a non-admin account to the admin group over ssh for a short period of time

# Temporary Admin Privilege Scripts

PowerShell scripts for granting time-limited administrator access to users.

## Configuration

Edit the following variables at the top of each script:

| Script | Variable | Description |
|--------|----------|-------------|
| admin-grant.ps1 | `$user` | User to grant temporary admin access |
| admin-grant.ps1 | `$adminUser` | Admin account whose password is required |
| admin-revoke.ps1 | `$user` | User to revoke admin access from |
| admin-status.ps1 | `$user` | User to check admin status for |

---

## Scripts

### admin-grant.ps1

Temporarily add a user to the Administrators group. Requires admin account password.

```powershell
.\admin-grant.ps1              # 30 minutes (default)
.\admin-grant.ps1 -Minutes 60  # 1 hour
```

**Requires:** Admin privileges, admin account password

### admin-revoke.ps1

Manually remove a user from Administrators before the timer expires.

```powershell
.\admin-revoke.ps1
```

### admin-status.ps1

Check if the user currently has admin privileges and when they expire.

```powershell
.\admin-status.ps1
```

---

## Workflow

1. Admin grants access:
   ```powershell
   .\admin-grant.ps1 -Minutes 60
   Enter password for admin_user: ********
   ```

2. Target user disconnects and reconnects SSH

3. User now has full admin — all commands run elevated automatically

4. After timeout (or manual revoke), access is removed

5. User reconnects to drop back to normal privileges

---

## Installation

```powershell
mkdir C:\bin -ErrorAction SilentlyContinue
Copy-Item admin-grant.ps1, admin-revoke.ps1, admin-status.ps1 C:\bin\
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\bin", "Machine")
```
