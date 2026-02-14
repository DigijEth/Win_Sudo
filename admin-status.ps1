$user = ""
$group = "Administrators"
$taskName = "Remove-$user-Admin"

$isAdmin = (Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*\$user" })

if ($isAdmin) {
    Write-Host "$user is currently in $group" -ForegroundColor Green
    
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        $trigger = ($task | Get-ScheduledTaskInfo).NextRunTime
        Write-Host "Auto-revoke scheduled: $trigger" -ForegroundColor Cyan
    } else {
        Write-Host "No auto-revoke scheduled (permanent until manual revoke)" -ForegroundColor Yellow
    }
} else {
    Write-Host "$user is NOT in $group" -ForegroundColor Yellow
}
