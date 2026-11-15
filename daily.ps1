# daily.ps1 — ежедневный коммит. Запускается Планировщиком задач Windows.
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
        git commit -m "auto: изменения за $today" | Out-Null
        Say "закоммичены изменения за $today"
    }

    $last = git log -1 --format="%cd" --date=short
    if ($last -ne $today) {
        $n = [int](git rev-list --count HEAD) + 1
        if (-not (Test-Path $journal)) { "# Дневник`n`n" | Out-File $journal -Encoding utf8 }
        Add-Content -Path $journal -Value "- $today — день $n." -Encoding utf8
        git add -A
        git commit -m "daily: $today" | Out-Null
        Say "ежедневный коммит за $today"
    }
    else {
        Say "коммит за $today уже есть"
    }

    git push origin main 2>&1 | Out-Null
    Say 'push ok'
}
catch {
    Say "ERROR: $_"
    exit 1
}
