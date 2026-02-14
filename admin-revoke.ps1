#Requires -RunAsAdministrator

$user = ""
$group = "Administrators"
$taskName = "Remove-$user-Admin"

# Remove from Administrators
$isAdmin = (Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*\$user" })
if ($isAdmin) {
    Remove-LocalGroupMember -Group $group -Member $user
    Write-Host "$user removed from $group" -ForegroundColor Green
} else {
    Write-Host "$user is not in $group" -ForegroundColor Yellow
}

# Cancel scheduled task
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "Admin access revoked. user must reconnect SSH for changes to apply." -ForegroundColor Cyan
