#Requires -RunAsAdministrator
param(
    [int]$Minutes = 30
)

$user = "snake"
$group = "Administrators"

# Check if already admin
$isAdmin = (Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*\$user" })
if ($isAdmin) {
    Write-Host "$user is already in $group" -ForegroundColor Yellow
    exit 0
}

# Add to Administrators
Add-LocalGroupMember -Group $group -Member $user
Write-Host "$user added to $group for $Minutes minutes" -ForegroundColor Green

# Schedule removal task
$taskName = "Remove-$user-Admin"
$removeTime = (Get-Date).AddMinutes($Minutes)

# Remove any existing task
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -Command `"Remove-LocalGroupMember -Group '$group' -Member '$user' -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false`""
$trigger = New-ScheduledTaskTrigger -Once -At $removeTime
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null

Write-Host "Auto-revoke at: $($removeTime.ToString('HH:mm:ss'))" -ForegroundColor Cyan
Write-Host "Manual revoke: .\admin-revoke.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: snake must log out and back in (or reconnect SSH) for admin to take effect!" -ForegroundColor Yellow
