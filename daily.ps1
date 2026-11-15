# daily.ps1 - makes at least one commit per day and pushes it.
# Runs from Windows Task Scheduler. Keep this file ASCII-only.

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
Set-Location $repo
$today = Get-Date -Format 'yyyy-MM-dd'
$journal = Join-Path $repo 'journal.md'
$log = Join-Path $repo 'daily.log'

function Say($m) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m
    Add-Content -Path $log -Value $line -Encoding utf8
}

try {
    $dirty = git status --porcelain
    if ($dirty) {
        git add -A
        git commit -m "auto: changes $today" | Out-Null
        Say "committed pending changes"
    }

    $last = git log -1 --format='%cd' --date=short
    if ($last -ne $today) {
        $n = [int](git rev-list --count HEAD) + 1
        if (-not (Test-Path $journal)) {
            Set-Content -Path $journal -Value '# Journal', '' -Encoding utf8
        }
        Add-Content -Path $journal -Value ('- {0} - day {1}' -f $today, $n) -Encoding utf8
        git add -A
        git commit -m "daily: $today" | Out-Null
        Say "daily commit made"
    }
    else {
        Say "commit for $today already exists"
    }

    git push origin main 2>&1 | Out-Null
    Say 'push ok'
}
catch {
    Say ('ERROR: ' + $_)
    exit 1
}
